import bnb/warband.{type Warband, Warband}
import bnb/warband/allegiance.{type Allegiance}
import bnb/warband/model.{type Model, Model}
import bnb/warband/species.{type Species}
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui
import bnb/util

pub fn main() {
  let app = lustre.application(init, update, view)
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

fn init(_flags) -> #(State, Effect(Msg)) {
  #(State(warband: warband.new(), menu: WarbandCreation(None)), effect.none())
}

// ------------------------- UPDATE -------------------------

type Msg {
  DoNothing
  UserUpdatedWarbandName(new_name: String)
  UserClickedAddModel
  UserAddedModel(species: Species)
  UserUpdatedModelName(index: Int, new_name: String)
  UserStoppedEditingName
  UserStartedEditingName(index: Int)
  UserChangedModelPosition(from: Int, to: Int)
  UserRemovedModel(index: Int)
  UserChangedAllegiance(Allegiance)
}

const name_input_id = "model-name-input"

fn update(state: State, msg: Msg) -> #(State, Effect(Msg)) {
  let State(warband:, ..) = state

  case msg {
    DoNothing -> #(state, effect.none())
    UserUpdatedWarbandName(new_name) -> #(
      State(..state, warband: Warband(..warband, name: new_name)),
      effect.none(),
    )
    UserClickedAddModel -> #(State(..state, menu: AddModel), effect.none())

    UserUpdatedModelName(index:, new_name:) -> #(
      State(
        ..state,
        warband: Warband(
          ..warband,
          models: warband.models
            |> util.update_index(at: index, with: fn(model) {
              Model(..model, name: new_name)
            }),
        ),
      ),
      effect.none(),
    )
    UserAddedModel(species) -> {
      let last_model = warband.model_count
      #(
        State(
          menu: WarbandCreation(Some(last_model)),
          warband: Warband(
            ..warband,
            models: warband.models |> util.append(model.new(species)),
            model_count: warband.model_count + 1,
          ),
        ),
        effect.from(fn(dispatch) {
          dispatch(UserStartedEditingName(last_model))
        }),
      )
    }
    UserStoppedEditingName -> #(
      State(..state, menu: WarbandCreation(None)),
      effect.none(),
    )
    UserStartedEditingName(index) -> #(
      State(..state, menu: WarbandCreation(Some(index))),
      effect.from(fn(_) {
        request_animation_frame(fn() { focus(name_input_id) })
      }),
    )
    UserChangedModelPosition(from:, to:) -> {
      #(
        State(
          ..state,
          warband: Warband(
            ..warband,
            models: util.swap(warband.models, from, to)
              |> result.unwrap(warband.models),
          ),
        ),
        effect.none(),
      )
    }
    UserRemovedModel(index) -> {
      #(
        State(
          ..state,
          warband: Warband(
            ..warband,
            models: util.remove(warband.models, index),
          ),
        ),
        effect.none(),
      )
    }
    UserChangedAllegiance(allegiance) -> #(
      State(..state, warband: Warband(..warband, allegiance:)),
      effect.none(),
    )
  }
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
  let warband_name =
    ui.field(
      [],
      [element.text("Enter your warband's name:")],
      ui.input([
        attribute.value(warband.name),
        event.on_input(UserUpdatedWarbandName),
      ]),
      [],
    )

  let warband_allegiance =
    ui.field(
      [],
      [element.text("Choose your allegiance")],
      html.select(
        [
          attribute.style([
            #("padding", "0.5em"),
            #("background-color", "var(--element-background)"),
          ]),
          event.on_input(fn(string) {
            string
            |> allegiance.from_string
            |> result.unwrap(allegiance.Royalist)
            |> UserChangedAllegiance
          }),
        ],
        allegiance.allegiances
          |> list.map(fn(allegiance) {
            html.option(
              [attribute.selected(allegiance == warband.allegiance)],
              allegiance |> allegiance.to_string,
            )
          }),
      ),
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

  ui.stack(
    [],
    list.flatten([[warband_name, warband_allegiance], models_ui, [add_model]]),
  )
}

fn add_model_view() -> Element(Msg) {
  ui.stack(
    [],
    list.map(species.species() |> dict.to_list, fn(pair) {
      let #(name, species) = pair
      ui.button([event.on_click(UserAddedModel(species))], [element.text(name)])
    }),
  )
}

fn model_view(model: Model, index: Int, editing_name: Bool) -> Element(Msg) {
  let name_element = case editing_name {
    False ->
      html.span([], [
        ui.tag([], [element.text(model.name)]),
        ui.button(
          [
            event.on_click(UserStartedEditingName(index)),
            attribute.style([
              #("font-size", "0.7em"),
              #("padding", "0"),
              #("margin", "2px"),
            ]),
          ],
          [element.text("✏️")],
        ),
      ])
    True ->
      ui.input([
        attribute.style([#("font-size", "0.7em"), #("max-width", "10em")]),
        attribute.id(name_input_id),
        attribute.value(model.name),
        event.on_input(UserUpdatedModelName(index:, new_name: _)),
        event.on_keydown(fn(key) {
          case key {
            "Enter" -> UserStoppedEditingName
            _ -> DoNothing
          }
        }),
        event.on_blur(UserStoppedEditingName),
      ])
  }

  let rank = case index {
    0 -> ui.tag([], [element.text("Leader")])
    1 ->
      html.span([], [
        ui.tag([], [element.text("Second")]),
        ui.button(
          [
            event.on_click(UserChangedModelPosition(from: index, to: 0)),
            attribute.style([#("font-size", "0.8em"), #("padding", "2px")]),
          ],
          [element.text("Make Leader")],
        ),
      ])
    _ ->
      html.span([], [
        ui.button(
          [
            event.on_click(UserChangedModelPosition(from: index, to: 0)),
            attribute.style([#("font-size", "0.8em"), #("padding", "2px")]),
          ],
          [element.text("Make Leader")],
        ),
        ui.button(
          [
            event.on_click(UserChangedModelPosition(from: index, to: 1)),
            attribute.style([#("font-size", "0.8em"), #("padding", "2px")]),
          ],
          [element.text("Make Second")],
        ),
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
      rank,
      ui.button(
        [
          event.on_click(UserRemovedModel(index:)),
          attribute.style([#("font-size", "0.9em"), #("padding", "0")]),
        ],
        [element.text("🗑️")],
      ),
      html.br([]),
      element.text("Species: "),
      ui.tag([], [element.text(model.species.name)]),
      element.text(" Name: "),
      name_element,
    ],
  )
}

@external(javascript, "./bnb_ffi.mjs", "focusElement")
fn focus(id: String) -> Nil

@external(javascript, "./bnb_ffi.mjs", "raf")
fn request_animation_frame(callback: fn() -> a) -> Nil
