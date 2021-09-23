function set_default (t, d) 
  setmetatable(t, {__index = function () return d end})
end

eq_meta = {__eq = function (x,y) return x[1] == y[1] and x[2] == y[2] end}

function point_equality(point)
  return setmetatable(point, eq_meta)
end

function lowest_point(open_points, point_map)
  curr_min = 1/0
  minimum_point = nil
  index = 0
  for i, curr_point in ipairs(open_points) do
    if (f[curr_point] < curr_min) then
      curr_min = f[curr_point]
      minimum_point = curr_point
      index = i
    end
  end
  return index, minimum_point
end

function heuristics(point, destination, grid)
  return math.abs(grid[point[1]][point[2]] - grid[destination[1]][destination[2]])
end

function shortest_path(start, destination, grid) 
  local _start = point_equality(start)
  local _destination = point_equality(destination)
  local closed_points = { }
  local open_points = { _start }
  g = { [_start] = 0 }
  set_default(g, 1/0)
  f = { [_start] = heuristics(_start, _destination, grid) }
  parent = {}
  
  while (#open_points > 0) do
    i, point = lowest_point(open_points, f)
    
    if (point == _destination) then
      return 
        -- uncomment below to check return the path
        -- recreate_path(_destination, parent),
        g[point]
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

-- returns the coordinates of `point` neighbours, if any exists
function neighbour_points(point, grid)
  local res = {}
  local offsets = {{0,-1}, {1,0}, {0,1}, {-1,0}}
  local x = point[1]
  local y = point[2]
  for _, offset in ipairs(offsets) do
    local new_x = x + offset[1]
    local new_y = y + offset[2]
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

function fcomb(first_set, second_set)
  res = {}
  comb(first_set, second_set, {}, res)
  return res
end

-- given two sets, 
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
      e = shortest_path(pair[1], pair[2], grid)
      if e then
        energy = energy + e
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

-- returns true if `points` is full of coordinates which 
-- result valid for a fly position (in `grid`)
function check_valid_points(points, grid)
  height = #grid
  width = #grid[1]
  for _,p in ipairs(points) do
    if (p[1] < 1 or p[1] > height) or (p[2] < 1 or p[2] > width) or grid[p[1]][p[2]] == 0 then return false end
  end
  return true
end

-- check if `grid` is valid
function is_grid_valid(grid)
  width = #grid[1]
  for _,row in ipairs(grid) do
    if #row ~= width then return false end -- error not rectangular
    for _,el in ipairs(row) do
      if el < 0 then return false end -- error not positive in grid
    end
  end
  if not check_valid_points(male, grid) or not check_valid_points(female, grid) then return false end -- invalid ant point

  return true
end

-- return the input sets ordered by number of elements
-- (male, female if male is smaller; female, male otherwise)
function order_sets(male, female)
  return #male <= #female and male, female or female, male
end

-- main program
do
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

  if not(is_grid_valid(grid)) then return end
  first_set, second_set = order_sets(male, female)
  result = fcomb(first_set, second_set)
  print(cheapest_comb(result))
end

