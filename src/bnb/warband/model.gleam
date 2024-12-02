import bnb/warband/species.{type Species}

pub type Model {
  Model(name: String, species: Species)
}

pub fn new(species: Species) -> Model {
  Model(name: "", species:)
}
