require 'spec_helper'
require 'beaker'
include Beaker::DSL::Wrappers
include Beaker::DSL::Patterns

describe BeakerWindows::Powershell do
  let(:dummy_class) { Class.new { extend BeakerWindows::Powershell } }
  let(:ps_cmd)      { "Write-Host 'Hello'" }
  let(:host)        { instance_double(Beaker::Host) }
  let(:result)      {
                      x = Beaker::Result.new('host', 'cmd')
                      x.stdout = 'This is stdout'
                      x.exit_code = '0'
                      x
                    }

  describe '#exec_ps_cmd' do

    it 'should wrap command in try/catch by default' do
      exp = "-Command \"try { #{ps_cmd} } catch { Write-Host \\$_.Exception.Message; exit 1 }\""

      expect(dummy_class.exec_ps_cmd(ps_cmd).args.last).to eq(exp)
    end

    it 'should wrap command in try/catch when specified' do
      exp = "-Command \"try { #{ps_cmd} } catch { Write-Host \\$_.Exception.Message; exit 1 }\""

      expect(dummy_class.exec_ps_cmd(ps_cmd, :excep_fail => true).args.last).to eq(exp)
    end

    it 'should not wrap command in try/catch when specified' do
      exp = "-Command \"#{ps_cmd}\""

      expect(dummy_class.exec_ps_cmd(ps_cmd, :excep_fail => false).args.last).to eq(exp)
    end

    it 'should validate command if specified' do
      exp = "-Command \"try { if ( #{ps_cmd} ) { exit 0 } else { exit 1 } } " \
            "catch { Write-Host \\$_.Exception.Message; exit 1 }\""

      expect(dummy_class.exec_ps_cmd(ps_cmd, :verify_cmd => true).args.last).to eq(exp)
    end

    it 'should validate command and wrap in try/catch when specified' do
      exp = "-Command \"try { if ( #{ps_cmd} ) { exit 0 } else { exit 1 } } " \
            "catch { Write-Host \\$_.Exception.Message; exit 1 }\""

      expect(dummy_class.exec_ps_cmd(ps_cmd, :excep_fail => true, :verify_cmd => true).args.last).to eq(exp)
    end

    it 'should encode a command if specified' do
      exp = "-EncodedCommand dAByAHkAIAB7ACAAVwByAGkAdABlAC0ASABvAHMAdAAgACcAS" \
            "ABlAGwAbABvACcAIAB9ACAAYwBhAHQAYwBoACAAewAgAFcAcgBpAHQAZQAtAEgAbw" \
            "BzAHQAIAAkAF8ALgBFAHgAYwBlAHAAdABpAG8AbgAuAE0AZQBzAHMAYQBnAGUAOwA" \
            "gAGUAeABpAHQAIAAxACAAfQA="

      expect(dummy_class.exec_ps_cmd(ps_cmd, :EncodedCommand => true).args.last).to eq(exp)
    end

    it 'should allow pass-thru PowerShell options' do
      exp = "-ExecutionPolicy Unrestricted"

      expect(dummy_class.exec_ps_cmd(ps_cmd, :ExecutionPolicy => 'Unrestricted').args).to include(exp)
    end

  end

  describe '#exec_ps_script_on' do

    it 'should wrap command in try/catch by default' do
      expect(dummy_class).to receive(:create_remote_file)
      expect(dummy_class).to receive(:on).exactly(1).times.and_return(result)
      expect(dummy_class).to receive(:powershell)
      expect{ dummy_class.exec_ps_script_on(host, ps_cmd) }.not_to raise_error
    end

  end
end
