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

function init_meta_grid()
  for i, row in ipairs(grid) do
    table.insert(meta_grid, {})
    for k, _ in ipairs(row) do
      table.insert(meta_grid[i], {i, k})
      ---meta_grid[i][k] = {i, k}
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
      print(k, v)
  end
end

function lowest_point(open_points, point_map)
  min = 10000000
  to_return = nil
  index = 0
  for i,point in ipairs(open_points) do
    if (point_map[point]["f"] < min) then
      min = point_map[point]["f"]
      to_return = point
      index = i
    end
  end
  return index, to_return
end

function shortest_path(start, destination, grid) 
  _start = to_meta(start)
  _destination = to_meta(destination)
  closed_points = { }
  open_points = { _start }
  point_map = { 
    [_start] = {g = 0, h = 0, f = 100, parent = {}}
  }
  
  while (#open_points > 0) do
    i, point = lowest_point(open_points, point_map)
    
    if (point == _destination) then
      print("Arrived")
      return "da fare"
    end
    
    table.remove(open_points, i)
    table.insert(closed_points, point)
    
    for _,neighbour in ipairs(neighbour_points(point, grid)) do
      _neighbour = to_meta(neighbour)
      if (not contains_point(closed_points, _neighbour)) then 
        
        t_g = point_map[point]["g"] + distance_between(point, _neighbour, grid)

        if (not contains_point(open_points, _neighbour)) then
          table.insert(open_points, _neighbour)
          better = true
        elseif (t_g < point_map[_neighbour]["g"]) then
          better = true
        else
          better = false
        end
        
        if (better) then
          point_map[_neighbour] = {g = t_g, h = 0, f = t_g + 0, parent = point}
        end
        
      end
      
    end
    
  end
  return nil
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
    if new_x > 0 and new_x < #grid[1] then
      if new_y > 0 and new_y < #grid then
        table.insert(res, {new_x, new_y})
      end
    end
  end
  return res
end

shortest_path({1,1}, {1,5}, grid)