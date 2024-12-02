import gleam/list
import gleam/result

pub fn update_index(
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

pub fn append(to list: List(element), append value: element) -> List(element) {
  list |> list.append([value])
}

pub fn swap(list: List(element), from, to) {
  use from_value <- result.try(at(list, from))
  use to_value <- result.map(at(list, to))

  use element, i <- list.index_map(list)
  case i {
    _ if i == from -> to_value
    _ if i == to -> from_value
    _ -> element
  }
}

fn at(list, i) {
  list
  |> list.index_map(fn(element, i) { #(element, i) })
  |> list.find_map(fn(pair) {
    case pair.1 == i {
      False -> Error(Nil)
      True -> Ok(pair.0)
    }
  })
}
