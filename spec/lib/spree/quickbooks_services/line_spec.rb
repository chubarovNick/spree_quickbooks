describe SpreeQuickbooks::Services::Line do
  let(:account) { double("Account", id: 76) }
  let(:payload) do
    {
        'order' => Factories.order,
        'return' => Factories.return_authorization
    }.with_indifferent_access
  end

  subject { described_class.new payload }


  it '.build_from_line_items' do
    VCR.use_cassette('line/build_from_line_items', match_requests_on: [:body, :method]) do
      expect(subject.build_from_line_items(account).count).to eq payload[:order][:line_items].count
    end
  end

  it '.build_from_adjustments' do
    VCR.use_cassette('line/build_from_adjustments', match_requests_on: [:body, :method]) do
      items = subject.build_from_adjustments(account)
      expect(items.count).to eq payload[:order][:adjustments].count
      expect(items.select{|i|i['sku'] == 'Shipping'}.count).to eq(2)

    end
  end

  it '.build_from_inventory_units' do
    VCR.use_cassette('line/build_from_inventory_units', match_requests_on: [:body, :method]) do
      expect(subject.build_from_inventory_units(account).count).to eq payload[:return][:inventory_units].count
    end
  end

  it 'just build' do
    VCR.use_cassette('line/build_them_all', match_requests_on: [:body, :method]) do
      total = payload[:order][:adjustments].count + payload[:order][:line_items].count
      expect(subject.build_lines.count).to eq total
    end
  end

end