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
end

def get_recipe_info
  recipe_info = db_connection do |conn|
    conn.exec('SELECT recipes.name, recipes.description, recipes.instructions, recipes.id FROM recipes')
  end
  recipe_info = recipe_info.to_a
end

def get_recipe_ingredients
  recipe_ingredients = db_connection do |conn|
    conn.exec('SELECT recipes.id, ingredients.name FROM recipes
    JOIN ingredients ON ingredients.recipe_id = recipes.id')
  end
  recipe_ingredients = recipe_ingredients.to_a
end


get '/recipes/' do
  @recipes = get_recipes
  erb :'index.html'
end

get '/recipes/:id' do
  @recipe_info = get_recipe_info
  @recipe_info.each do |recipe|
    if recipe["id"] == params[:id]
      @recipe_info = recipe
    end
    @recipe_info
  end
  @recipe_ingredients = get_recipe_ingredients
  @final_ingredients = []
  @recipe_ingredients.each do |ingredient|
    if ingredient["recipe_id"] == params[:id]
      @final_ingredients << ingredient
    end
  @final_ingredients
  end

  erb :'recipe.html'
end
