import bnb/warband/model.{type Model}
import bnb/warband/allegiance.{type Allegiance}

pub type Warband {
  Warband(
    name: String,
    allegiance: Allegiance,
    models: List(Model),
    model_count: Int,
    max_models: Int,
  )
}

pub fn new() -> Warband {
  Warband(
    name: "",
    allegiance: allegiance.Royalist,
    models: [],
    model_count: 0,
    max_models: 10,
  )
}
