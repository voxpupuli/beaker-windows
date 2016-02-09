require 'spec_helper'

describe BeakerWindows::Path do
  let(:dummy_class) { Class.new { extend BeakerWindows::Path } }
  let(:path_1)                 { 'c:\cats' }
  let(:path_2)                 { 'go\meow' }
  let(:path_3)                 { 'and\dogs\go\bark' }

  describe '#join_path' do

    it 'should combine simple paths' do
      exp = 'c:\cats\go\meow\and\dogs\go\bark'

      expect(dummy_class.join_path(path_1, path_2, path_3)).to eq(exp)
    end

    it 'should combine paths using alternate separator' do
      exp = 'c:/cats/go/meow/and/dogs/go/bark'

      expect(dummy_class.join_path(path_1, path_2, path_3, :path_sep => '/')).to eq(exp)
    end

    it 'should combine paths and strip drive letter' do
      exp = '\cats\go\meow\and\dogs\go\bark'

      expect(dummy_class.join_path(path_1, path_2, path_3, :strip_drive => true)).to eq(exp)
    end

    it 'should combine paths using alternate separator and strip drive letter' do
      exp = '/cats/go/meow/and/dogs/go/bark'

      expect(dummy_class.join_path(path_1, path_2, path_3, :path_sep => '/', :strip_drive => true)).to eq(exp)
    end

    it 'should combine paths with mixed separators' do
      path_1 = 'c:\cats\go\meow'
      path_2 = 'and/dogs/go/bark'
      exp = 'c:\cats\go\meow\and\dogs\go\bark'

      expect(dummy_class.join_path(path_1, path_2)).to eq(exp)
    end

    it 'should combine paths with leading and trailing separators' do
      path_1 = "c:\\cats\\go\\meow\\"
      path_2 = '/and/dogs/go/bark'
      exp = 'c:\cats\go\meow\and\dogs\go\bark'

      expect(dummy_class.join_path(path_1, path_2)).to eq(exp)
    end

    it 'should combine paths with leading and trailing separators using alternate separator' do
      path_1 = "c:\\cats\\go\\meow\\"
      path_2 = '/and/dogs/go/bark'
      exp = 'c:/cats/go/meow/and/dogs/go/bark'

      expect(dummy_class.join_path(path_1, path_2, :path_sep => '/')).to eq(exp)
    end

    it 'should combine heinous paths' do
      path_1 = "c:\\//cats\\go\\\\\\meow\\\\"
      path_2 = '/////////and\\dogs/\go\\bark'
      exp = 'c:\cats\go\meow\and\dogs\go\bark'

      expect(dummy_class.join_path(path_1, path_2)).to eq(exp)
    end

    it 'should combine heinous paths using alternate separator' do
      path_1 = "c:\\//cats\\go\\\\\\meow\\\\"
      path_2 = '/////////and\\dogs/\go\\bark'
      exp = 'c:/cats/go/meow/and/dogs/go/bark'

      expect(dummy_class.join_path(path_1, path_2, :path_sep => '/')).to eq(exp)
    end

    context 'negative' do

      it 'should fail with only one path' do
        expect{ dummy_class.join_path(path_1) }.to raise_error(ArgumentError)
      end

      it 'should fail with invalid data type' do
        expect{ dummy_class.join_path(path_1, 3) }.to raise_error(ArgumentError)
      end

    end

  end

end

describe Beaker::DSL::Assertions do
  let(:dummy_class) { Class.new { extend Beaker::DSL::Assertions } }
  let(:host)        { instance_double(Beaker::Host) }
  let(:result)      {
                      x = Beaker::Result.new('host', 'cmd')
                      x.exit_code = 0
                      x
                    }
  let(:bkr_cmd)     { instance_double(Beaker::Command) }
  let(:ps_opts)     { {:verify_cmd=>true, :EncodedCommand=>true} }
  let(:test_path)   { 'c:\cats\and\stuff' }

    describe '#assert_win_path_on' do

    it 'should assert that a valid path exists' do
      ps_cmd = "Test-Path -Path '#{test_path}' -Type Any"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_opts).and_return(bkr_cmd)
      expect{ expect(dummy_class.assert_win_path_on(host, test_path)) }.not_to raise_error
    end

    it 'should assert that a valid directory path exists' do
      ps_cmd = "Test-Path -Path '#{test_path}' -Type Container"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_opts).and_return(bkr_cmd)
      expect{ expect(dummy_class.assert_win_path_on(host, test_path, :container)) }.not_to raise_error
    end

    it 'should assert that a valid file path exists' do
      ps_cmd = "Test-Path -Path '#{test_path}' -Type Leaf"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_opts).and_return(bkr_cmd)
      expect{ expect(dummy_class.assert_win_path_on(host, test_path, :leaf)) }.not_to raise_error
    end

    context 'negative' do

      it 'should raise assert exception if path does not exist' do
        ps_cmd = "Test-Path -Path '#{test_path}' -Type Any"
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_opts).and_return(bkr_cmd)
        expect{
          expect(dummy_class.assert_win_path_on(host, test_path))
        }.to raise_error(Minitest::Assertion)
      end

      it 'should raise exception if invalid path type is specified' do
        expect{
          dummy_class.assert_win_path_on(host, test_path, :bad)
        }.to raise_error(ArgumentError)
      end

    end

  end
end
