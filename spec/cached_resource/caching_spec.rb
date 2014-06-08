require 'spec_helper'
describe CachedResource do

  before(:each) do
    class Red < ActiveResource::Base
      self.site = 'http://api.buildersleagueunited.com'
    end

    class Blu < ActiveResource::Base
      self.site = 'http://api.reliableexcavationdemolition.com'
    end

    @red_one = Red.new(id: 1, string: 'One')
    @red_two = Red.new(id: 2, string: 'Two')
    @reds = [@red_one, @red_two]

    @blu_one = Blu.new(id: 1, string: 'One')
    @blu_two = Blu.new(id: 2, string: 'Two')
    @blus = [@blu_one, @blu_two]

    ActiveResource::HttpMock.reset!
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/reds.json',   {}, @reds.to_json
      mock.get '/reds/1.json', {}, @red_one.to_json
      mock.get '/reds/2.json', {}, @red_two.to_json

      mock.get '/blus.json',   {}, @blus.to_json
      mock.get '/blus/1.json', {}, @blu_one.to_json
      mock.get '/blus/2.json', {}, @blu_two.to_json
    end
  end

  after(:each) do
    CachedResourceLibrary::Cache.clear
  end

  context 'when enabled' do
    before(:each) do
      CachedResource::configuration.enable
    end
    
    describe '.find' do

      it 'returns a resource' do
        expect(Red.find(1)).to eq(@red_one)
        expect(Red.find(2)).to eq(@red_two)
      end

      it 'caches a resource' do
        Red.find(1)
        Red.find(1)
        expect(ActiveResource::HttpMock.requests.length).to eq(1)
      end

      it 'reloads a resource\'s cache' do
        Red.find(1)
        Red.find(1, reload: true)
        expect(ActiveResource::HttpMock.requests.length).to eq(2)
      end

    end
    describe '.all' do

      it 'returns a collection' do
        expect(Red.all.to_json).to eq(@reds.to_json)
      end

      it 'caches a collection from cache' do
        Red.all
        Red.all
        expect(ActiveResource::HttpMock.requests.length).to eq(1)
      end

      it 'reloads a collection\'s cache' do
        Red.all
        Red.find(:all, reload: true)
        expect(ActiveResource::HttpMock.requests.length).to eq(2)
      end

    end
    describe 'cache clearing' do

      before(:each) do
        Red.find(1)
        Red.find(2)
        Blu.find(1)
        Blu.all
      end

      it 'clears all of the cache' do
        CachedResource.clear_cache

        Red.find(1)
        Red.find(2)
        Blu.find(1)
        Blu.all
        expect(ActiveResource::HttpMock.requests.length).to eq(4 + 4)
      end

      it 'clears the classes cache' do
        Red.clear_cache

        Red.find(1)
        Red.find(2)
        Blu.find(1)
        Blu.all
        expect(ActiveResource::HttpMock.requests.length).to eq(4 + 2)
      end

      it 'clears the instances cache' do
        instance = Blu.find(1)
        instance.clear_cache

        Red.find(1)
        Red.find(2)
        Blu.find(1)
        Blu.all
        expect(ActiveResource::HttpMock.requests.length).to eq(4 + 1)
      end
    end
  end

  context 'when disabled' do
    
    before(:each) do
      CachedResource::configuration.disable
    end
    
    describe '.find' do

      it 'returns a resource' do
        expect(Red.find(1)).to eq(@red_one)
        expect(Red.find(2)).to eq(@red_two)
      end

      it 'does not cache a resource' do
        Red.find(1)
        Red.find(1)
        expect(ActiveResource::HttpMock.requests.length).to eq(2)
      end

    end
    describe '.all' do

      it 'returns a collection' do
        expect(Red.all.to_json).to eq(@reds.to_json)
      end

      it 'does not cache a collection' do
        Red.all
        Red.all
        expect(ActiveResource::HttpMock.requests.length).to eq(2)
      end

    end
  end
  context 'when configuring' do
    
    it 'sets global settings' do
      Red.find(1)
      Red.find(1)
      expect(ActiveResource::HttpMock.requests.length).to eq(2)
      
      CachedResource.enable
      expect(CachedResource.enabled?).to eq(true)
      
      Red.find(1)
      Red.find(1)
      expect(ActiveResource::HttpMock.requests.length).to eq(3)
    end
    
    it 'allows class to overide settings' do
      CachedResource.disable
      expect(CachedResource.enabled?).to eq(false)
      
      Red.enable_cache
      expect(Red.cache_enabled?).to eq(true)
      
      Red.find(1)
      Red.find(1)
      
      Blu.find(1)
      Blu.find(1)
      expect(ActiveResource::HttpMock.requests.length).to eq(3)
    end
    
  end
end
