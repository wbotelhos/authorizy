# frozen_string_literal: true

Rails.application.routes.draw do
  get :action, to: 'admin/dummy#action'
  get :action, to: 'dummy#action'
end
