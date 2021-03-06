# frozen_string_literal: true

ORG = 'HeRoMo'
REPO = "#{ORG}/github-repo-stats"

RSpec.describe GithubRepoStats::CLI do
  describe 'subcommand: repo', vcr: { cassette_name: 'github-repo-stats/cli/repo' } do
    subject do
      capture(output) do
        args = %W[repo --repo #{REPO} --start-month #{start_month} --end-month #{end_month}]
        described_class.start(args)
      end
    end

    let(:output) { :stdout }
    let(:start_month) { '2020-12' }
    let(:end_month) { '2020-12' }

    context 'When valid params' do
      it 'output successfully' do
        parsed_subject = JSON.parse(subject, symbolize_names: true)

        expect(parsed_subject).to include(:pull_requests)
        expect(parsed_subject).to include(:author_counts)
        expect(parsed_subject).to include(:review_counts)
        expect(parsed_subject).to include(:start_month)
        expect(parsed_subject).to include(:end_month)
      end
    end

    context 'When invalid params' do
      let(:output) { :stderr }
      let(:start_month) { '12020-12' }

      it 'show error message' do
        expect(subject).to start_with 'Invalid start-month'
      end
    end
  end

  describe 'subcommand: org', vcr: { cassette_name: 'github-repo-stats/cli/org' } do
    subject do
      capture(output) do
        args = %W[org --org #{ORG} --start-month #{start_month} --end-month #{end_month}]
        described_class.start(args)
      end
    end

    let(:output) { :stdout }
    let(:start_month) { '2020-12' }
    let(:end_month) { '2020-12' }

    context 'When valid params' do
      it 'output successfully' do
        parsed_subject = JSON.parse(subject, symbolize_names: true)

        expect(parsed_subject).to include(:'github-repo-stats')
        expect(parsed_subject).to include(:start_month)
        expect(parsed_subject).to include(:end_month)
        expect(parsed_subject[:'github-repo-stats']).to include(:pull_requests)
        expect(parsed_subject[:'github-repo-stats']).to include(:author_counts)
        expect(parsed_subject[:'github-repo-stats']).to include(:review_counts)
      end
    end

    context 'When invalid params' do
      let(:output) { :stderr }
      let(:start_month) { '12020-12' }

      it 'show error message' do
        expect(subject).to start_with 'Invalid start-month'
      end
    end
  end
end
