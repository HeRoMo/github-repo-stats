# frozen_string_literal: true

ORG = 'HeRoMo'
REPO = "#{ORG}/github-repo-stats"

RSpec.describe GithubRepoStats::Client do
  describe '#pulls_of_repo' do
    subject { described_class.new.pulls_of_repo(REPO, start_month, end_month) }

    context 'when valid params', vcr: { cassette_name: 'github-repo-stats/client/pulls_of_repo' } do
      let(:start_month) { '2020-12' }
      let(:end_month) { '2020-12' }

      it 'run successfully' do
        expect(subject).to include(:pull_requests)
        expect(subject).to include(:author_counts)
        expect(subject).to include(:review_counts)
        expect(subject).to include(:start_month)
        expect(subject).to include(:end_month)
      end
    end
  end

  describe '#pulls_of_org' do
    subject { described_class.new.pulls_of_org(ORG, start_month, end_month) }

    context 'when valid params', vcr: { cassette_name: 'github-repo-stats/client/pulls_of_org' } do
      let(:start_month) { '2020-12' }
      let(:end_month) { '2020-12' }

      it 'run successfully' do
        expect(subject).to include('github-repo-stats')
        expect(subject).to include(:start_month)
        expect(subject).to include(:end_month)
        expect(subject['github-repo-stats']).to include(:pull_requests)
        expect(subject['github-repo-stats']).to include(:author_counts)
        expect(subject['github-repo-stats']).to include(:review_counts)
      end
    end
  end

  describe '#terms' do
    subject { described_class.new.send(:terms, start_month, end_month) }

    context 'when single month' do
      let(:start_month) { '2020-12' }
      let(:end_month) { '2020-12' }

      it 'has one term' do
        expect(subject).to match_array ['2020-12-01..2020-12-31']
      end
    end

    context 'when who month' do
      let(:start_month) { '2020-11' }
      let(:end_month) { '2020-12' }

      it 'has two terms' do
        expect(subject).to match_array ['2020-11-01..2020-11-30', '2020-12-01..2020-12-31']
      end
    end

    context 'when invalid start-month' do
      let(:start_month) { '2020-111' }
      let(:end_month) { '2020-12' }

      it 'raise error' do
        expect { subject }.to raise_error('Invalid start-month')
      end
    end

    context 'when invalid end-month' do
      let(:start_month) { '2020-11' }
      let(:end_month) { '12020-12' }

      it 'raise error' do
        expect { subject }.to raise_error('Invalid end-month')
      end
    end
  end
end
