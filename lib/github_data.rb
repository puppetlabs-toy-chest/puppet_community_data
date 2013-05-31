require 'octokit'
require 'table_print'
require 'chronic'
require 'json'
require 'csv'
require 'google_drive'

class GitHubData
    # Collect recently closed pull requests and print out some
    # relevent data about them
    puppet_pulls = Octokit.pull_requests('puppetlabs/puppet', 'closed')
    tp puppet_pulls, "title", "number", "created_at", "closed_at", "merged_at"

    # Use these to keep track of some info we will want later
    pull_requests = Hash.new
    num_merged = 0
    total_pull_requests = 0

    # Go through each pull request, calculate it's lifetime,
    # then store it in a new has with it's number as a key
    # and it's lifetime (in minutes) as a value
    puppet_pulls.each do |key, value|
       if(key['merged_at'] != nil)
            num_merged = num_merged +1
            was_merged = true
        end

        total_pull_requests = total_pull_requests + 1
        open_time = key['created_at']
        open_time = (Chronic.parse(open_time)).to_time
        close_time = key['closed_at']
        close_time = (Chronic.parse(close_time)).to_time
        pull_request_num = key['number']
        pull_request_ttl = ((close_time - open_time)/60).to_i
        pull_requests[pull_request_num] = [pull_request_ttl,was_merged]
    end

    # Create an array to keep track of all the pull request 
    # lifetimes
    pull_request_lifetimes = Array.new

    puts "\n|Here is a list of recently closed pull requests in puppet:|\n"

    pull_requests.each do |key, value|
        puts "The pull request number is: #{key} And it's lifetime is: #{value} minutes"
        pull_request_lifetimes.push(value[0])
    end

    # Calculate some info about pull request lifetimes
    # and then print it out
    shortest = pull_request_lifetimes.min
    longest = pull_request_lifetimes.max
    total = pull_request_lifetimes.inject(:+)
    len = pull_request_lifetimes.length
    average = (total.to_f / len).to_i
    sorted = pull_request_lifetimes.sort
    median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_i / 2
    percent_merged = ((num_merged.to_f / total_pull_requests.to_f) * 100).to_i

    puts "\n|Here is some neat data about the lifetime of recently closed pull requests:|\n"
    puts "The shortest pull request lifetime was #{shortest} minutes"
    puts "The longest pull request lifetime was #{longest} minutes"
    puts "The average pull request lifetime was #{average} minutes"
    puts "The median pull request lifetime was #{median} minutes"
    puts "At least #{percent_merged}% of the pull requests were merged"

    # Write the hash of pull requests and their lifetimes to a json file
    json_file_path = File.absolute_path('/Users/haileekenney/Projects/puppet_community_data/data/lifetimes.json')

    File.open(json_file_path, 'w') do |file|
      file.puts(JSON.generate(pull_requests))
    end

    # Write the array of pull request lifetimes to a csv file
    csv_file_path = '/Users/haileekenney/Projects/puppet_community_data/data/lifetimes.csv'

    CSV.open(csv_file_path, 'w') do |csv|
        csv << pull_request_lifetimes
    end
end