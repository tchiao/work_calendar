require 'spec_helper'

module WorkCalendar
  describe Configuration do
    describe '#configure' do
      context 'with no config arguments' do
        before { WorkCalendar.configure {} }

        it 'defaults the config weekdays to an empty array' do
          expect(WorkCalendar.config.weekdays).to match_array([])
        end

        it 'defaults the config holidays to an empty array' do
          expect(WorkCalendar.config.holidays).to match_array([])
        end
      end

      context 'with invalid config attributes' do
        it 'raises an error' do
          expect { WorkCalendar.configure { |c| c.made_up_param = 'abc' } }
            .to raise_error(NoMethodError)
        end
      end

      context 'with valid config arguments' do
        before do
          WorkCalendar.configure do |c|
            c.weekdays = %i(mon wed)
            c.holidays = [Date.new(2013, 4, 1)]
          end
        end

        it 'sets the config weekdays correctly' do
          expect(WorkCalendar.config.weekdays).to match_array([:mon, :wed])
        end

        it 'sets the config holidays correctly' do
          expect(WorkCalendar.config.holidays)
            .to match_array([Date.new(2013, 4, 1)])
        end
      end
    end
  end

  describe WorkCalendar do
    before do
      WorkCalendar.configure do |c|
        c.weekdays = %i(mon tue wed thu fri)
        c.holidays = [Date.new(2015, 1, 1), Date.new(2015, 7, 3),
                      Date.new(2015, 12, 25)]
      end
    end

    describe '#active?' do
      context 'when the date is an active work day' do
        it 'returns true' do
          expect(WorkCalendar.active?(Date.new(2015, 1, 2))).to be true
        end
      end

      context 'when the date is a non-work day' do
        context 'when it is a holiday' do
          it 'returns false' do
            expect(WorkCalendar.active?(Date.new(2015, 1, 1))).to be false
          end
        end

        context 'when it is not a weekday' do
          it 'returns false' do
            expect(WorkCalendar.active?(Date.new(2015, 1, 3))).to be false
          end
        end
      end
    end

    describe '#days_before' do
      let(:start_date) { Date.new(2015, 1, 8) }

      context 'when days before is 0' do
        it 'returns the same date' do
          expect(WorkCalendar.days_before(0, start_date)).to eq(start_date)
        end
      end

      context 'when days before is positive' do
        it 'returns the correct date' do
          expect(WorkCalendar.days_before(5, start_date))
            .to eq(Date.new(2014, 12, 31))
        end
      end

      context 'when days before is negative' do
        it 'raises an error' do
          expect { WorkCalendar.days_before(-5, start_date) }
            .to raise_error(ArgumentError)
        end
      end
    end

    describe '#days_after' do
      let(:start_date) { Date.new(2015, 1, 1) }

      context 'when days after is 0' do
        it 'returns the same date' do
          expect(WorkCalendar.days_after(0, start_date)).to eq(start_date)
        end
      end

      context 'when days after is positive' do
        it 'returns the correct date' do
          expect(WorkCalendar.days_after(5, start_date))
            .to eq(Date.new(2015, 1, 8))
        end
      end

      context 'when days after is negative' do
        it 'raises an error' do
          expect { WorkCalendar.days_after(-5, start_date) }
            .to raise_error(ArgumentError)
        end
      end
    end

    describe '#between' do
      context 'when both days are the same' do
        it 'returns an empty array' do
          expect(WorkCalendar.between(Date.new(2014, 12, 30),
                                      Date.new(2014, 12, 30))).to eq([])
        end
      end

      context 'when the second date is later than the first' do
        it 'returns all the active dates in between' do
          dates = WorkCalendar.between(Date.new(2014, 12, 30),
                                       Date.new(2015, 1, 15))
          results = [Date.new(2014, 12, 30), Date.new(2014, 12, 31),
                     Date.new(2015, 1, 2), Date.new(2015, 1, 5),
                     Date.new(2015, 1, 6), Date.new(2015, 1, 7),
                     Date.new(2015, 1, 8), Date.new(2015, 1, 9),
                     Date.new(2015, 1, 12), Date.new(2015, 1, 13),
                     Date.new(2015, 1, 14)]
          expect(dates).to match_array(results)
        end
      end

      context 'when the second date is earlier than the first' do
        it 'raises an error' do
          expect {
            WorkCalendar.between(Date.new(2015, 1, 15),
                                 Date.new(2014, 12, 30))
          }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
