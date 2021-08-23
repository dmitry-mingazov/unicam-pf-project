grid = {
  {1 , 2 , 0 , 4 , 5},
  {6 , 7 , 8 , 0 , 10},
  {11, 17, 8 , 0 , 0},
  {1 , 1 , 8 , 0 , 10}
}

meta_grid = {}

male = {
  {1, 2},
  {3, 1}
} 

female = {
  {4, 2},
  {4, 3},
  {2, 5}
}

function set_default (t, d)
  local mt = {__index = function () return d end}
  setmetatable(t, mt)
end

function init_meta_grid()
  for i, row in ipairs(grid) do
    table.insert(meta_grid, {})
    for k, _ in ipairs(row) do
      table.insert(meta_grid[i], {i, k})
    end
  end
end

function to_meta(point)
  return meta_grid[point[1]][point[2]]
end


init_meta_grid()
  

function print_grid(grid, male, female) 
  for _,row in ipairs(grid) do
    for _,col in ipairs(row) do
      io.write(col .. "\t")
    end
    print()
  end
end

function debug_table(table) 
  for k,v in pairs(table) do
      io.write(k .. ":" .. v)
      print()
  end
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
  _start = to_meta(start)
  _destination = to_meta(destination)
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
      _neighbour = to_meta(neighbour)
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
    if v[1] == el[1] and v[2] == el[2] then return true end
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

function main()
  for _,m in pairs(male) do
    for _,f in pairs(female) do
      result = shortest_path(m, f, grid)
        print("----------------------------------------")
        print("Male: {"..m[1]..","..m[2].."} - Female: {"..f[1]..","..f[2].."}")
      if result then
        print("E: "..result["energy"])
      else
        print("No path found")
      end
    end
  end
end

main()

--result = shortest_path({1,1}, {3,3}, grid)



--if result then
  --print("Energy spent: " .. result["energy"])
  --for _,v in pairs(result["path"]) do
    --print(v[1] .. " " .. v[2])
 -- end
--else
--  print("No Solution")
--en
