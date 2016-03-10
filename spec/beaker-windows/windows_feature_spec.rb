require 'spec_helper'
require 'beaker'

describe BeakerWindows::Powershell do
  let(:dummy_class) { Class.new { extend BeakerWindows::WindowsFeature } }
  let(:host)        { instance_double(Beaker::Host) }
  let(:result)      {
                      x = Beaker::Result.new('host', 'cmd')
                      x.exit_code = 0
                      x
                    }
  let(:bkr_cmd)     { instance_double(Beaker::Command) }

  describe '#get_windows_features_on' do

    it 'should return all features by default' do
      ps_cmd = 'Get-WindowsFeature | Select -ExpandProperty Name'
      result.stdout = "feature1\nfeature2\nfeature3"
      exp = ['feature1','feature2','feature3']

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{ expect(dummy_class.get_windows_features_on(host)).to eq(exp) }.not_to raise_error
    end

    it 'should return only installed features when specified' do
      ps_cmd = 'Get-WindowsFeature | Where { \$_.Installed -Eq \$true } | Select -ExpandProperty Name'
      result.stdout = "feature1\nfeature2\nfeature3"
      exp = ['feature1','feature2','feature3']

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{
        expect(dummy_class.get_windows_features_on(host, :filter => :installed)).to eq(exp)
      }.not_to raise_error
    end

    it 'should return only available features when specified' do
      ps_cmd = 'Get-WindowsFeature | Where { \$_.Installed -Eq \$false } | Select -ExpandProperty Name'
      result.stdout = "feature1\nfeature2\nfeature3"
      exp = ['feature1','feature2','feature3']

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{
        expect(dummy_class.get_windows_features_on(host, :filter => :available)).to eq(exp)
      }.not_to raise_error
    end

    context 'negative' do

      it 'should fail with invalid filter' do
        expect{ dummy_class.get_windows_features_on(host, :filter => :bad) }.to raise_error(ArgumentError)
      end

      it 'should fail with incorrect PowerShell version' do
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).and_return(bkr_cmd)
        expect{ dummy_class.get_windows_features_on(host) }.to raise_error(RuntimeError)
      end

    end

  end

  describe '#install_windows_feature_on' do

    it 'should install a feature' do
      feature_name = 'Print-Server'
      ps_cmd = "(Install-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
      result.stdout = 'True'

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{ expect(dummy_class.install_windows_feature_on(host, feature_name)) }.not_to raise_error
    end

    it 'should install a feature with failure suppression' do
      feature_name = 'Print-Server'
      ps_cmd = "(Install-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
      result.stdout = 'True'

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{
        expect(dummy_class.install_windows_feature_on(host, feature_name, :suppress_fail => true))
      }.not_to raise_error
    end

    context 'negative' do

      it 'should raise exception if installation fails' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Install-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
        result.stdout = 'False'

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{ dummy_class.install_windows_feature_on(host, feature_name) }.to raise_error(RuntimeError)
      end

      it 'should raise exception with incorrect PowerShell version' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Install-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
        result.stdout = 'False'
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{ dummy_class.install_windows_feature_on(host, feature_name) }.to raise_error(RuntimeError)
      end

      it 'should NOT raise exception if installation fails with failure suppression enabled' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Install-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
        result.stdout = 'False'
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{
          dummy_class.install_windows_feature_on(host, feature_name, :suppress_fail => true)
        }.not_to raise_error
      end

    end

  end

  describe '#remove_windows_feature_on' do

    it 'should remove a feature' do
      feature_name = 'Print-Server'
      ps_cmd = "(Remove-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
      result.stdout = 'True'

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{ expect(dummy_class.remove_windows_feature_on(host, feature_name)) }.not_to raise_error
    end

    it 'should remove a feature with failure suppression' do
      feature_name = 'Print-Server'
      ps_cmd = "(Remove-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
      result.stdout = 'True'

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{
        expect(dummy_class.remove_windows_feature_on(host, feature_name, :suppress_fail => true))
      }.not_to raise_error
    end

    context 'negative' do

      it 'should raise exception if removal fails' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Remove-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
        result.stdout = 'False'

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{ dummy_class.remove_windows_feature_on(host, feature_name) }.to raise_error(RuntimeError)
      end

      it 'should raise exception with incorrect PowerShell version' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Remove-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
        result.stdout = 'False'
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{ dummy_class.remove_windows_feature_on(host, feature_name) }.to raise_error(RuntimeError)
      end

      it 'should NOT raise exception if removal fails with failure suppression enabled' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Remove-WindowsFeature -Name '#{feature_name}' -ErrorAction 'Stop').Success"
        result.stdout = 'False'
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{
          dummy_class.remove_windows_feature_on(host, feature_name, :suppress_fail => true)
        }.not_to raise_error
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

    describe '#assert_windows_feature_on' do

    it 'should assert that a feature is installed' do
      feature_name = 'Print-Server'
      ps_cmd = "(Get-WindowsFeature -Name '#{feature_name}').InstallState -Eq 'Installed'"
      result.stdout = 'True'

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{ expect(dummy_class.assert_windows_feature_on(host, feature_name)) }.not_to raise_error
    end

    it 'should assert that a feature is available' do
      feature_name = 'Print-Server'
      ps_cmd = "(Get-WindowsFeature -Name '#{feature_name}').InstallState -Eq 'Available'"
      result.stdout = 'True'

      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
      expect{
        expect(dummy_class.assert_windows_feature_on(host, feature_name, :state => :available))
      }.not_to raise_error
    end

    context 'negative' do

      it 'should raise assert exception if feature is not installed' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Get-WindowsFeature -Name '#{feature_name}').InstallState -Eq 'Installed'"
        result.stdout = 'False'

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{
          dummy_class.assert_windows_feature_on(host, feature_name, :state => :installed)
        }.to raise_error(Minitest::Assertion)
      end

      it 'should raise assert exception if feature is not available' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Get-WindowsFeature -Name '#{feature_name}').InstallState -Eq 'Available'"
        result.stdout = 'False'

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{
          dummy_class.assert_windows_feature_on(host, feature_name, :state => :available)
        }.to raise_error(Minitest::Assertion)
      end

      it 'should raise exception with incorrect PowerShell version' do
        feature_name = 'Bad-Feature'
        ps_cmd = "(Get-WindowsFeature -Name '#{feature_name}').InstallState -Eq 'Installed'"
        result.stdout = 'False'
        result.exit_code = 1

        expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
        expect(dummy_class).to receive(:exec_ps_cmd).with(ps_cmd).and_return(bkr_cmd)
        expect{
          dummy_class.assert_windows_feature_on(host, feature_name)
        }.to raise_error(RuntimeError)
      end

    end

  end
end
