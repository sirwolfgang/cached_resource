require 'spec_helper'

describe CachedResource do
  
  before(:each) do
    class Resource < ActiveResource::Base
      self.site = "http://api.test.com"
      #cached_resource
    end
  
    @resource_one = Resource.new(id: 1, string: 'One')
    @resource_two = Resource.new(id: 2, string: 'Two')
    @resources = [@resource_one, @resource_two]
    
    ActiveResource::HttpMock.reset!
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get   "/resources.json",   {}, @resources.to_json
      mock.get   "/resources/1.json", {}, @resource_one.to_json
      mock.get   "/resources/2.json", {}, @resource_two.to_json
    end
  end
    
  after(:each) do
    CachedResource::Cache.clear
    Object.send(:remove_const, :Resource)
  end
  
  context 'when enabled' do
    describe '.find' do
      
      it 'returns a resource' do
        expect(Resource.find(1)).to eq(@resource_one)
      end
      
      it 'caches a resource' do
        Resource.find(1)
        Resource.find(1)
        expect(ActiveResource::HttpMock.requests.length).to eq(1)
      end
      
      it 'reloads a resource\'s cache' do
        Resource.find(1)
        Resource.find(1, reload: true)
        expect(ActiveResource::HttpMock.requests.length).to eq(2)
      end

    end
    describe'.all' do
      
      it 'returns a collection' do
        expect(Resource.all.to_json).to eq(@resources.to_json)
      end
      
      it 'caches a collection from cache' do
        Resource.all
        Resource.all
        expect(ActiveResource::HttpMock.requests.length).to eq(1)
      end
      
      it 'reloads a collection\'s cache' do
        Resource.all
        Resource.find(:all, reload: true)
        expect(ActiveResource::HttpMock.requests.length).to eq(2)
      end

    end
  end
  
  context 'when disabled' do
    describe '.find' do
      # TODO
    end
    describe'.all' do
      # TODO
    end
  end
  
end