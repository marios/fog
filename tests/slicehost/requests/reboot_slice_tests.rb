Shindo.tests('Slicehost#reboot_slice', 'slicehost') do
  tests('success') do

    before do
      @data = Slicehost[:slices].create_slice(1, 3, 'fogrebootslice').body
      @id = @data['id']
      Fog.wait_for { Slicehost[:slices].get_slice(@id).body['status'] == 'active' }
      @data = Slicehost[:slices].reboot_slice(@id).body
    end

    after do
      Fog.wait_for { Slicehost[:slices].get_slice(@id).body['status'] == 'active' }
      Slicehost[:slices].delete_slice(@id)
    end

    test('has proper output format') do
      has_format(@data, Slicehost::Formats::SLICE)
    end

  end

  tests('failure') do

    test('raises Forbidden error if flavor does not exist') do
      has_error(Excon::Errors::Forbidden) do
        Slicehost[:slices].reboot_slice(0)
      end
    end

  end
end
