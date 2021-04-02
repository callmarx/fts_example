up:
	docker-compose up --build api

exec:
	docker-compose exec api bundle exec $(filter-out $@, $(MAKECMDGOALS))

console:
	docker-compose exec api bundle exec rails console

lint:
	docker-compose exec api bundle exec rubocop
	docker-compose exec api brakeman
	docker-compose exec api rubycritic

prepare-db:
	docker cp ./pt_br.affix fts-example-db:/usr/share/postgresql/13/tsearch_data/pt_br.affix
	docker cp ./pt_br.dict fts-example-db:/usr/share/postgresql/13/tsearch_data/pt_br.dict
	docker-compose exec api bundle exec rails db:create db:migrate db:seed
	docker-compose exec api bundle exec "rails db:create RAILS_ENV=test"

refresh-db:
	docker-compose exec api bundle exec rails db:drop db:create db:migrate db:seed

test:
	docker-compose exec api bundle exec rspec $(filter-out $@, $(MAKECMDGOALS))
