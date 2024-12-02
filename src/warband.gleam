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
    allegiance: Royalist,
    models: [],
    model_count: 0,
    max_models: 10,
  )
}

pub type Model {
  Model(name: String, species: String)
}

pub fn model(species: String) -> Model {
  Model(name: "", species:)
}

pub type Allegiance {
  Royalist
  Rogue
  FreeBeast
  WildBeast
}

pub const allegiances = [Royalist, Rogue, FreeBeast, WildBeast]

pub fn allegiance_string(allegiance: Allegiance) -> String {
  case allegiance {
    Royalist -> "Royalists"
    Rogue -> "Rogues"
    FreeBeast -> "Freebeasts"
    WildBeast -> "Wildbeasts"
  }
}

pub fn allegiance_from_string(string: String) -> Result(Allegiance, Nil) {
  case string {
    "Royalists" -> Ok(Royalist)
    "Rogues" -> Ok(Rogue)
    "Freebeasts" -> Ok(FreeBeast)
    "Wildbeasts" -> Ok(WildBeast)
    _ -> Error(Nil)
  }
}
