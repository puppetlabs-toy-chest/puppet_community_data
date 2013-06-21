module PuppetCommunityData
  class Repository
    attr_reader :owner, :name

    def initialize(repository)
      @owner, @name = repository.split('/')
    end

    def full_name
      [@owner, @name].join('/')
    end
  end
end
