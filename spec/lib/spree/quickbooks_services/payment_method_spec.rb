describe SpreeQuickbooks::Services::PaymentMethod do
  let(:payload) do
    {
        'order' => Factories.order
    }.with_indifferent_access
  end

  let(:message) do
    { :payload => payload }.with_indifferent_access
  end

  subject { described_class.new payload }

  context '.augury_name' do
    it 'picks credit card if provided' do
      message[:payload][:order][:payments][0][:payment_method] = "Visa"
      expect(subject.augury_name).to eq "Visa"
    end

    it 'picks payment method name if credit card not provided' do
      message[:payload][:order][:credit_cards] = []
      expect(subject.augury_name).to eq payload[:order][:payments].first[:payment_method]
    end
  end

  context '.matching_payment' do

    it 'maps qb_name and store names properly' do
      expect(subject.qb_name).to eq 'Discover'
    end

    it 'raise when cant find method in quickbooks' do
      subject.quickbooks.stub fetch_by_name: nil

      expect {
        subject.matching_payment
      }.to raise_error
    end

  end


end