require 'spec_helper'
require 'beaker'

describe BeakerWindows::Powershell do
  let(:dummy_class) { Class.new { extend BeakerWindows::Registry } }
  let(:host)        { instance_double(Beaker::Host) }
  let(:result)      {
                      x = Beaker::Result.new('host', 'cmd')
                      x.exit_code = 0
                      x
                    }
  let(:bkr_cmd)     { instance_double(Beaker::Command) }
  let(:ps_cmd_opt)  { {:EncodedCommand=>true} }
  let(:reg_hive)    { :hklm }
  let(:reg_path)    { 'fake\registry\path' }
  let(:reg_value)   { 'reg_value' }
  let(:reg_data)    { 'fake_registry_data' }

  describe '#_get_hive' do

    it 'should return translated path for :hklm' do
      reg_hive = :hklm
      exp = "HKLM:\\"

      expect{
        expect(dummy_class._get_hive(reg_hive)).to eq(exp)
      }.not_to raise_error
    end

    it 'should return translated path for :hkcu' do
      reg_hive = :hkcu
      exp = "HKCU:\\"

      expect{
        expect(dummy_class._get_hive(reg_hive)).to eq(exp)
      }.not_to raise_error
    end

    it 'should return translated path for :hku' do
      reg_hive = :hku
      exp = "HKU:\\"

      expect{
        expect(dummy_class._get_hive(reg_hive)).to eq(exp)
      }.not_to raise_error
    end

    context 'negative' do

      it 'should fail if invalid hive specified' do
        reg_hive = :bad

        expect{
          dummy_class._get_hive(reg_hive)
        }.to raise_error(ArgumentError)
      end

    end

  end

  describe '#get_registry_value_on' do

    it 'should return data for valid registry path' do
      ps_cmd = "(Get-Item -Path 'HKLM:\\#{reg_path}').GetValue('#{reg_value}')"
      result.stdout = "#{reg_data}\n"
      exp = reg_data

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
      expect{
        expect(dummy_class.get_registry_value_on(host, reg_hive, reg_path, reg_value)).to eq(exp)
      }.not_to raise_error
    end

    context 'negative' do

      it 'should fail if invalid path is specified' do
        ps_cmd = "(Get-Item -Path 'HKLM:\\#{reg_path}').GetValue('#{reg_value}')"
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
        expect{
          dummy_class.get_registry_value_on(host, reg_hive, reg_path, reg_value)
        }.to raise_error(RuntimeError)
      end

    end

  end

  describe '#set_registry_value_on' do

    it 'should create value for string type' do
      ps_cmd = "New-ItemProperty -Force -Path " \
               "'HKLM:\\#{reg_path}' -Name '#{reg_value}'" \
               " -Value '#{reg_data}' -PropertyType String"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
      expect{
        dummy_class.set_registry_value_on(host, reg_hive, reg_path, reg_value, reg_data)
      }.not_to raise_error
    end

    it 'should create value for dword type' do
      reg_data = 1
      ps_cmd = "New-ItemProperty -Force -Path " \
               "'HKLM:\\#{reg_path}' -Name '#{reg_value}'" \
               " -Value #{reg_data} -PropertyType DWord"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
      expect{
        dummy_class.set_registry_value_on(host, reg_hive, reg_path, reg_value, reg_data, :dword)
      }.not_to raise_error
    end

    it 'should create value for bin type' do
      reg_data = 'be,ef,f0,0d'
      ps_cmd = "New-ItemProperty -Force -Path " \
               "'HKLM:\\#{reg_path}' -Name '#{reg_value}'" \
               " -Value ([byte[]](0xbe,0xef,0xf0,0x0d)) -PropertyType Binary"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
      expect{
        dummy_class.set_registry_value_on(host, reg_hive, reg_path, reg_value, reg_data, :bin)
      }.not_to raise_error
    end

    context 'negative' do

      it 'should fail if invalid data type specified' do
        expect{
          dummy_class.set_registry_value_on(host, reg_hive, reg_path, reg_value, reg_data, :bad)
        }.to raise_error(ArgumentError)
      end

      it 'should fail if invalid string format used for binary data type' do
        reg_data = 'not valid binary data'

        expect{
          dummy_class.set_registry_value_on(host, reg_hive, reg_path, reg_value, reg_data, :bin)
        }.to raise_error(ArgumentError)
      end

      it 'should fail if invalid path is specified' do
        ps_cmd = "New-ItemProperty -Force -Path " \
                 "'HKLM:\\#{reg_path}' -Name '#{reg_value}'" \
                 " -Value '#{reg_data}' -PropertyType String"
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
        expect{
          dummy_class.set_registry_value_on(host, reg_hive, reg_path, reg_value, reg_data)
        }.to raise_error(RuntimeError)
      end

    end

  end

  describe '#remove_registry_value_on' do

    it 'should remove value for valid registry path' do
      ps_cmd = "Remove-ItemProperty -Force -Path 'HKLM:\\#{reg_path}' -Name '#{reg_value}'"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
      expect{
        dummy_class.remove_registry_value_on(host, reg_hive, reg_path, reg_value)
      }.not_to raise_error
    end

    context 'negative' do

      it 'should fail if invalid path is specified' do
        ps_cmd = "Remove-ItemProperty -Force -Path 'HKLM:\\#{reg_path}' -Name '#{reg_value}'"
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
        expect{
          dummy_class.remove_registry_value_on(host, reg_hive, reg_path, reg_value)
        }.to raise_error(RuntimeError)
      end

    end

  end

  describe '#new_registry_key_on' do

    it 'should create a new key for a valid path' do
      ps_cmd = "New-Item -Force -Path 'HKLM:\\#{reg_path}'"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
      expect{
        dummy_class.new_registry_key_on(host, reg_hive, reg_path)
      }.not_to raise_error
    end

    context 'negative' do

      it 'should fail if invalid path is specified' do
        ps_cmd = "New-Item -Force -Path 'HKLM:\\#{reg_path}'"
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
        expect{
          dummy_class.new_registry_key_on(host, reg_hive, reg_path)
        }.to raise_error(RuntimeError)
      end

    end

  end

  describe '#remove_registry_key_on' do

    it 'should remove a valid key path' do
      ps_cmd = "Remove-Item -Force -Path 'HKLM:\\#{reg_path}'"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
      expect{
        dummy_class.remove_registry_key_on(host, reg_hive, reg_path)
      }.not_to raise_error
    end

    it 'should recursively remove a valid key path' do
      ps_cmd = "Remove-Item -Force -Path 'HKLM:\\#{reg_path}' -Recurse"

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
      expect{
        dummy_class.remove_registry_key_on(host, reg_hive, reg_path, true)
      }.not_to raise_error
    end

    context 'negative' do

      it 'should fail if invalid path is specified' do
        ps_cmd = "Remove-Item -Force -Path 'HKLM:\\#{reg_path}'"
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd, ps_cmd_opt).and_return(bkr_cmd)
        expect{
          dummy_class.remove_registry_key_on(host, reg_hive, reg_path)
        }.to raise_error(RuntimeError)
      end

    end

  end
end
