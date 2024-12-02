import bnb/warband/allegiance.{type Allegiance}
import bnb/warband/model.{type Model}

pub type Warband {
  Warband(
    name: String,
    allegiance: Allegiance,
    models: List(Model),
    model_count: Int,
    pennies: Int,
  )
}

pub const max_models = 10

pub fn new() -> Warband {
  Warband(
    name: "",
    allegiance: allegiance.Royalist,
    models: [],
    model_count: 0,
    pennies: 350,
  )
}
