class GithubRepository < ActiveRecord::Base
  # validations (presense and uniqueness)

  has_many :projects
  has_many :github_contributions

  def to_s
    full_name
  end

  def owner_name
    full_name.split('/')[0]
  end

  def project_name
    full_name.split('/')[1]
  end

  def pages_url
    "http://#{owner_name}.github.io/#{project_name}"
  end

  def wiki_url
    "#{url}/wiki"
  end

  def watchers_url
    "#{url}/watchers"
  end

  def forks_url
    "#{url}/network"
  end

  def stargazers_url
    "#{url}/stargazers"
  end

  def issues_url
    "#{url}/issues"
  end

  def contributors_url
    "#{url}/graphs/contributors"
  end

  def url
    "https://github.com/#{full_name}"
  end

  def avatar_url(size = 60)
    "https://avatars.githubusercontent.com/u/#{owner_id}?size=#{size}"
  end

  def download_github_contributions
    contributions = projects.first.github_client.contributors(full_name)
    return false if contributions.empty?
    contributions.each do |c|
      p c.login
      user = GithubUser.find_or_create_by(github_id: c.id) do |u|
        u.login = c.login
        u.user_type = c.type
      end
      cont = github_contributions.find_or_create_by(github_user: user)
      cont.count = c.contributions
      cont.platform = projects.first.platform
      cont.save
    end
  rescue
    p full_name
  end
end
