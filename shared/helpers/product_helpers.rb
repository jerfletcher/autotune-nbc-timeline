# Helpers for dealing with products in the Gift Guides
module ProductHelpers
  SPAN_ENTIRE_ROW_CLASSES = %w(double_wide doublewide double-wide splitgroup split-group split_group group)
  ITEMS_PER_ROW = 2

  # Loop through an array of products, returning one or two items at a time, depending on content
  def product_looper(products, items_per_row=ITEMS_PER_ROW)
    row = []
    row_count = 0

    for p in products
      if SPAN_ENTIRE_ROW_CLASSES.include? p['class']
        yield [p], row_count
        row_count += 1
      else
        row << p
        if row.length == items_per_row
          yield row, row_count
          row = []
          row_count += 1
        end
      end
    end

    if row.length > 0 && row.length < items_per_row
      row += [nil] * (items_per_row - row.length)
      yield row, row_count
    end
  end
end
