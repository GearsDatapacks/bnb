pub type Warband {
  Warband(name: String, models: List(Model), model_count: Int, max_models: Int)
}

pub fn new() -> Warband {
  Warband(name: "", models: [], model_count: 0, max_models: 10)
}

pub type Model {
  Model(name: String, species: String)
}

pub fn model(species: String) -> Model {
  Model(name: "", species:)
}
