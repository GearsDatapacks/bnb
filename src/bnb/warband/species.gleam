import bnb/lazy.{Lazy}
import gleam/dict.{type Dict}
import gleam/list

pub type Species {
  Species(cost: Int, name: String)
}

const species_registry = [
  Species(cost: 53, name: "Hare"),
  Species(cost: 62, name: "Wildcat"),
  Species(cost: 65, name: "Badger"),
  Species(cost: 62, name: "Armadillo"),
  Species(cost: 30, name: "Mole"),
  Species(cost: 31, name: "Rabbit"),
  Species(cost: 43, name: "Fox"),
  Species(cost: 51, name: "Otter"),
  Species(cost: 31, name: "Hedgehog"),
]

const lazy_species = Lazy(get_species)

fn get_species() {
  species_registry
  |> list.map(fn(species) { #(species.name, species) })
  |> dict.from_list
}

pub fn species() -> Dict(String, Species) {
  lazy_species |> lazy.get
}
