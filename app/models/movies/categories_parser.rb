module Movies
  class CategoriesParser < ActsAsTaggableOn::GenericParser
    def parse
      ActsAsTaggableOn::TagList.new.tap do |tag_list|
        filtered_tags = @tag_list.split(',').select do |tag|
          Movie::CATEGORIES.include?(tag)
        end

        tag_list.add(filtered_tags)
      end
    end
  end
end
