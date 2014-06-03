require 'sinatra'
require 'pg'
require 'shotgun'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipe_box')

    yield(connection)

  ensure
    connection.close
  end
end

def get_recipes
  recipes = db_connection do |conn|
    conn.exec('SELECT name, id FROM recipes')
  end
  recipes = recipes.to_a
  recipes = recipes.sort_by {|recipe| recipe["name"]}
end

def get_recipe_info(recipe_id)
  query = 'SELECT name, description, instructions FROM recipes WHERE recipes.id = $1'
  recipe_info = db_connection do |conn|
    conn.exec_params(query, [recipe_id])
  end
  recipe_info = recipe_info.to_a
end

def get_recipe_ingredients(recipe_id)
  query = 'SELECT ingredients.name FROM ingredients JOIN recipes ON recipes.id = ingredients.recipe_id WHERE recipes.id = $1'
  recipe_ingredients = db_connection do |conn|
    conn.exec_params(query, [recipe_id])

  end
  recipe_ingredients = recipe_ingredients.to_a
end


get '/recipes/' do
  @recipes = get_recipes
  erb :'index.html'
end

get '/recipes/:id' do
  @recipe_id = params[:id]
  @recipe_info = get_recipe_info(@recipe_id)

  @recipe_ingredients = get_recipe_ingredients(@recipe_id)

  erb :'recipe.html'
end
