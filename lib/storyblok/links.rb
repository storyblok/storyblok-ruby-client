module Storyblok
  class Links
    def initialize(response_obj)
      @links = response_obj['data']['links']
    end

    def as_tree
      tree = {}

      @links.each do |key, item|
        if tree[item['parent_id']].nil?
          tree[item['parent_id']] = []
        end

        tree[item['parent_id']] << item
      end

      generate_tree(0, tree)
    end

    private

    def generate_tree(parent_id = 0, items)
      tree = {}

      if !items[parent_id].nil?
        result = items[parent_id]

        result.each do |item|
          if tree[item['id']].nil?
            tree[item['id']] = {}
          end

          tree[item['id']]['item'] = item
          tree[item['id']]['children'] = generate_tree(item['id'], items)
        end
      end

      tree
    end
  end
end
