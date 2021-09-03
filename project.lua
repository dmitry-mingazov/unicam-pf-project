function set_default (t, d) 
  setmetatable(t, {__index = function () return d end})
end

eq_meta = {__eq = function (x,y) return x[1] == y[1] and x[2] == y[2] end}

function point_equality(point)
  return setmetatable(point, eq_meta)
end

function lowest_point(open_points, point_map)
  min = 1/0
  to_return = nil
  index = 0
  for i,point in ipairs(open_points) do
    if (f[point] < min) then
      min = f[point]
      to_return = point
      index = i
    end
  end
  return index, to_return
end

function heuristics(point, destination, grid)
  return math.abs(grid[point[1]][point[2]] - grid[destination[1]][destination[2]])
end

function shortest_path(start, destination, grid) 
  _start = point_equality(start)
  _destination = point_equality(destination)
  closed_points = { }
  open_points = { _start }
  g = { [_start] = 0 }
  set_default(g, 1/0)
  f = { [_start] = heuristics(_start, _destination, grid) }
  parent = {}
  
  while (#open_points > 0) do
    i, point = lowest_point(open_points, f)
    
    if (point == _destination) then
      return {
        path = recreate_path(_destination, parent),
        energy = g[point]
        }
    end
    
    table.remove(open_points, i)
    table.insert(closed_points, point)
    
    for _,neighbour in ipairs(neighbour_points(point, grid)) do
      _neighbour = point_equality(neighbour)
      if (not contains_point(closed_points, _neighbour)) then 
        
        t_g = g[point] + distance_between(point, _neighbour, grid)
        
        if (t_g < g[_neighbour]) then
          g[_neighbour] = t_g
          f[_neighbour] = t_g + heuristics(_neighbour, _destination, grid)
          parent[_neighbour] = point
          if (not contains_point(open_points, _neighbour)) then
            table.insert(open_points, _neighbour)
          end
        end
      end
    end
  end
  return nil
end

function recreate_path(destination, parent)
  current = destination
  final = {}
  while parent[current] ~= nil do
    table.insert(final, 1, current)
    current = parent[current]
  end
  return final
end

function distance_between(point, neighbour, grid)
  return math.abs(grid[point[1]][point[2]] - grid[neighbour[1]][neighbour[2]])
end

function contains_point(array, el) 
  for _,v in ipairs(array) do
    if v == el then return true end
  end
  return false
end

function neighbour_points(point, grid)
  res = {}
  offsets = {{0,-1}, {1,0}, {0,1}, {-1,0}}
  local x = point[1]
  local y = point[2]
  for _, offset in ipairs(offsets) do
    new_x = x + offset[1]
    new_y = y + offset[2]
    if new_x > 0 and new_x <= #grid then
      if new_y > 0 and new_y <= #grid[1] then
        if grid[new_x][new_y] ~= 0 then
          table.insert(res, {new_x, new_y})
        end
      end
    end
  end
  return res
end

function comb(first_set, second_set, seq, result)
  if #first_set == 0 then
    final_seq = {}
    for _,k in ipairs(seq) do
      table.insert(final_seq, {k[1], k[2]})
    end
    table.insert(result, final_seq)
  else
    local seq_male = first_set[1]
    table.remove(first_set, 1)
    for i,f in ipairs(second_set) do
      table.insert(seq, {seq_male, f})
      table.remove(second_set, i)
      comb(first_set, second_set, seq, result)
      table.remove(seq, #seq)
      table.insert(second_set, i, f)
    end
    table.insert(first_set, 1, seq_male)
  end
end

function cheapest_comb(combs)
  min_energy = 1/0
  for i,comb in ipairs(combs) do
    energy = 0
    for _,pair in pairs(comb) do
      sp = shortest_path(pair[1], pair[2], grid)
      if sp then
       energy = energy + sp["energy"]
      else
        energy = 1/0
      end
    end
    if energy < min_energy then
      min_energy = energy
    end
  end
  return min_energy
end

function check_valid_points(points, grid)
  height = #grid
  width = #grid[1]
  for _,p in ipairs(points) do
    if (p[1] < 1 or p[1] > height) or (p[2] < 1 or p[2] > width) or grid[p[1]][p[2]] == 0 then return false end
  end
  return true
end

function main()
  width = #grid[1]
  
  for _,row in ipairs(grid) do
    if #row ~= width then return end -- error not rectangular
    for _,el in ipairs(row) do
      if el < 0 then return end -- error not positive in grid
    end
  end
  
  if not check_valid_points(male, grid) or not check_valid_points(female, grid) then return end -- invalid ant point
  
  result = {} 
  first_set = #male <= #female and male or female
  second_set = #male <= #female and female or male
  comb(first_set, second_set, {}, result)
  print(cheapest_comb(result))
end

grid = {
  {1 , 2 , 0 , 4 , 5},
  {6 , 7 , 8 , 0 , 10},
  {11, 17, 8 , 0 , 0},
  {1 , 1 , 8 , 0 , 10}
}

male = {
  {1, 2},
  {3, 1}
} 

female = {
  {4, 2},
  {4, 3},
  {2, 5}
}

main()