import gleam/list
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/event
import lustre/ui
import warband.{type Model, type Warband, Warband}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// ------------------------- INIT -------------------------

fn init(_flags) -> Warband {
  warband.new()
}

// ------------------------- UPDATE -------------------------

pub type Msg {
  UpdatedWarbandName(new_name: String)
  AddedModel
  UpdatedModelName(index: Int, new_name: String)
}

fn update(warband: Warband, msg: Msg) -> Warband {
  case msg {
    UpdatedWarbandName(new_name) -> Warband(..warband, name: new_name)
    AddedModel ->
      Warband(
        ..warband,
        models: warband.models |> list.append([warband.Model("")]),
        model_count: warband.model_count + 1,
      )

    UpdatedModelName(index:, new_name:) ->
      Warband(
        ..warband,
        models: warband.models
          |> update_index(at: index, with: fn(_model) {
            warband.Model(name: new_name)
          }),
      )
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

// ------------------------- VIEW -------------------------

fn view(warband: Warband) -> element.Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]

  let warband_ui =
    ui.field(
      [],
      [element.text("Enter your warband's name:")],
      ui.input([
        attribute.value(warband.name),
        event.on_input(UpdatedWarbandName),
      ]),
      [],
    )

  let models_ui = list.index_map(warband.models, model_view)

  let add_model =
    ui.button(
      [
        event.on_click(AddedModel),
        attribute.disabled(warband.model_count == warband.max_models),
      ],
      [element.text("Add a model")],
    )

  ui.centre(
    [attribute.style(styles)],
    ui.stack([], list.flatten([[warband_ui], models_ui, [add_model]])),
  )
}

fn model_view(model: Model, index: Int) -> Element(Msg) {
  ui.field(
    [],
    [element.text("Enter your model's name:")],
    ui.input([
      attribute.value(model.name),
      event.on_input(UpdatedModelName(index:, new_name: _)),
    ]),
    [],
  )
}
