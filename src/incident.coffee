# Description:
#  Orderly incident coordination through hubot
#
# Dependencies:
#   "<module name>": "<module version>"
#
# Configuration:
#   HUBOT_GITHUB_TOKEN (required)
#   HUBOT_GITHUB_ORG (required)
#
# Commands:
#   hubot incident start - Initiate incident
#   hubot incident ack - Aknowledge started incident
#   hubot incident end - Resolve incident
#
# Notes:
#   <optional notes required for the script>
#
# Authors:
#   Aaron Blythe
#   Levi Smith

moment = require('moment')
#GitHubApi = require "github"
checklists = require('./documentation/checklist_md')

module.exports = (robot) ->
#  ghToken       = process.env.HUBOT_GITHUB_TOKEN
#  ghOrg         = process.env.HUBOT_GITHUB_ORG

  robot.respond /incident (start|initiate)/i, (msg) ->
    # Probably set to the brain via the notify portion of the bot in non-hacky version
    robot.brain.set 'incidentNumber', 8675309
    incidentNumber = robot.brain.get('incidentNumber')
    now = moment()
    time = now.format('YYYY-MM-DD HH:mm:ss Z')
    msg.send "INCIDENT NOTIFY: Incident #{incidentNumber} has been started"
    msg.emote "creates gitbucket repo for incident #{incidentNumber}"
    msg.emote "creates leankit card for incident #{incidentNumber}"
    msg.emote "has started logging all conversation in this room as of #{time}"
    checklists.getChecklist 'start', (err, content) ->
      if err?
        robot.emit 'error', err, msg
        return
      msg.send formatMarkDown(content)


  robot.respond /incident (ack|acknowledge)/i, (msg) ->
    incidentNumber = robot.brain.get('incidentNumber')
    msg.send "INCIDENT NOTIFY: Acknowledged incident #{incidentNumber}"

  robot.respond /incident (end|resolve)/i, (msg) ->
    incidentNumber = robot.brain.get('incidentNumber')
    msg.send "INCIDENT NOTIFY: Resolved incident #{incidentNumber}"
    checklists.getChecklist 'end', (err, content) ->
      if err?
        robot.emit 'error', err, msg
        return
      msg.send formatMarkDown(content)

  robot.respond /incident help/i, (msg) ->
    commands = robot.helpCommands()
    commands = (command for command in commands when command.match(/incident/))
    msg.send commands.join("\n")



  formatMarkDown = (content) ->
    block = "```\n"
    block += content
    block += "```\n"
    block