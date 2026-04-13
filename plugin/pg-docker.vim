if exists('g:loaded_pg_docker') | finish | endif
let g:loaded_pg_docker = 1

lua require('pg-docker')._bootstrap()
