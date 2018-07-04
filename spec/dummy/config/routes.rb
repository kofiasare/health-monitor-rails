Rails.application.routes.draw do
  mount monitoring::Engine => '/health'
end
