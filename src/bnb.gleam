import data
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui
import warband.{type Model, type Warband, Warband}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// ------------------------- INIT -------------------------

// Model is already a term in burrows and badgers
type State {
  State(warband: Warband, menu: Menu)
}

type Menu {
  WarbandCreation(editing_name: Option(Int))
  AddModel
}

fn init(_flags) -> State {
  State(warband: warband.new(), menu: WarbandCreation(None))
}

// ------------------------- UPDATE -------------------------

type Msg {
  UserUpdatedWarbandName(new_name: String)
  UserClickedAddModel
  UserAddedModel(species: String)
  UserUpdatedModelName(index: Int, new_name: String)
  UserStoppedEditingName
  UserStartedEditingName(index: Int)
}

fn update(state: State, msg: Msg) -> State {
  let State(warband:, ..) = state

  case msg {
    UserUpdatedWarbandName(new_name) ->
      State(..state, warband: Warband(..warband, name: new_name))
    UserClickedAddModel -> State(..state, menu: AddModel)

    UserUpdatedModelName(index:, new_name:) ->
      State(
        ..state,
        warband: Warband(
          ..warband,
          models: warband.models
            |> update_index(at: index, with: fn(model) {
              warband.Model(..model, name: new_name)
            }),
        ),
      )
    UserAddedModel(species) ->
      State(
        menu: WarbandCreation(Some(warband.model_count)),
        warband: Warband(
          ..warband,
          models: warband.models |> append(warband.model(species)),
          model_count: warband.model_count + 1,
        ),
      )
    UserStoppedEditingName -> State(..state, menu: WarbandCreation(None))
    UserStartedEditingName(index) ->
      State(..state, menu: WarbandCreation(Some(index)))
  }
}

fn update_index(
  in list: List(element),
  at index: Int,
  with update_fn: fn(element) -> element,
) -> List(element) {
  list.index_map(list, fn(element, i) {
    case i == index {
      False -> element
      True -> update_fn(element)
    }
  })
}

fn append(to list: List(element), append value: element) -> List(element) {
  list |> list.reverse |> list.prepend(value) |> list.reverse
}

// ------------------------- VIEW -------------------------

fn view(state: State) -> Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]
  let content = case state.menu {
    AddModel -> add_model_view()
    WarbandCreation(editing_name) ->
      warband_creation_view(state.warband, editing_name)
  }
  ui.centre([attribute.style(styles)], content)
}

fn warband_creation_view(
  warband: Warband,
  editing_name: Option(Int),
) -> Element(Msg) {
  let warband_ui =
    ui.field(
      [],
      [element.text("Enter your warband's name:")],
      ui.input([
        attribute.value(warband.name),
        event.on_input(UserUpdatedWarbandName),
      ]),
      [],
    )

  let models_ui =
    list.index_map(warband.models, fn(model, index) {
      let editing_name = editing_name == Some(index)
      model_view(model, index, editing_name)
    })

  let add_model =
    ui.button(
      [
        event.on_click(UserClickedAddModel),
        attribute.disabled(warband.model_count == warband.max_models),
      ],
      [element.text("Add a model")],
    )

  ui.stack([], list.flatten([[warband_ui], models_ui, [add_model]]))
}

fn add_model_view() -> Element(Msg) {
  ui.stack(
    [],
    list.map(data.species, fn(species) {
      ui.button([event.on_click(UserAddedModel(species))], [
        element.text(species),
      ])
    }),
  )
}

fn model_view(model: Model, index: Int, editing_name: Bool) -> Element(Msg) {
  let name_element = case editing_name {
    False ->
      html.span([], [
        ui.tag([], [element.text(model.name)]),
        ui.button([event.on_click(UserStartedEditingName(index)), attribute.style([#("font-size", "0.7em"), #("padding", "0"), #("margin", "2px")])], [
          element.text("✏️"),
        ]),
      ])
    True ->
      ui.input([
        attribute.style([#("font-size", "0.7em"), #("max-width", "10em")]),
        attribute.value(model.name),
        event.on_input(UserUpdatedModelName(index:, new_name: _)),
        event.on_blur(UserStoppedEditingName),
      ])
  }

  ui.box(
    [
      attribute.style([
        #("background-color", "rgba(226, 146, 255, 0.05)"),
        #("border", "2px solid rgb(226, 146, 255)"),
        #("border-radius", "10px"),
      ]),
    ],
    [
      element.text("Species: "),
      ui.tag([], [element.text(model.species)]),
      element.text("Name: "),
      name_element,
    ],
  )
}
