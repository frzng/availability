#!/usr/bin/env ruby

require 'date'
require 'bundler'

require 'rubinius/debugger'

Bundler.require

HOST = '3e.zonio.net'
PORT = 4444
TIMEOUT = 300

Result = Struct.new :actor, :success?, :email

user = EEE::Entities::User.new
n = Netrc.read
user.username, password = n[HOST]
today = Date.today.to_datetime
after_week = today + 7
empty_tz = RiCal.Timezone

Rubinius::Actor.trap_exit = true
ready_workers = []
busy_workers = []

task = ->(supervisor) do
  loop do
    attendee = Rubinius::Actor.receive

    success = false
    begin
      client = EEE::Scenario.new EEE::Methods::Client.new,
        'host' => HOST,
        'port' => PORT,
        'timeout' => TIMEOUT
      client.append_call :authenticate, user, password
      client.append_call :free_busy, attendee, today, after_week, empty_tz
      ok, response = client.send

      success = ok && !response.is_a?(XMLRPC::FaultException)
    rescue Net::ReadTimeout
      success = false
    end

    supervisor << Result[Rubinius::Actor.current, success, attendee.username]
  end
end

Facter.value('processors')['count'].times do
  ready_workers << Rubinius::Actor.spawn_link(Rubinius::Actor.current, &task)
end

check = ->(f) do
  f.when Result do |result|
    $stderr << "#{result.email} "

    if result.success?
      $stdout.puts 'OK'
    else
      $stdout.puts 'NOK'
    end

    busy_workers -= [result.actor]
    ready_workers << result.actor
  end
  f.when Rubinius::Actor::DeadActorError do |exit|
    $stderr.puts "Actor exited with message: #{exit.reason}"

    busy_workers -= [exit.actor]
    ready_workers << Rubinius::Actor.spawn_link(Rubinius::Actor.current, &task)
  end
end

loop do
  line = $stdin.gets
  break unless line

  attendee = EEE::Entities::User.new
  attendee.username = line.chomp

  Rubinius::Actor.receive &check if ready_workers.empty?

  worker = ready_workers.shift
  busy_workers << worker
  worker << attendee
end

Rubinius::Actor.receive &check until busy_workers.empty?
