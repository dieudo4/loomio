angular.module('loomioApp').controller 'InboxPageController', ($rootScope, Records, CurrentUser, LoadingService) ->
  $rootScope.$broadcast('currentComponent', 'inboxPage')
  $rootScope.$broadcast('setTitle', 'Inbox')

  @groupThreadCounts =
    collapsed: 0
    normal:    5
    expanded:  10

  @loadInbox = ->
    Records.discussions.fetchInbox()
  LoadingService.applyLoadingFunction @, 'loadInbox'

  @allDiscussionsFor = (group) ->
    Records.discussions.forInbox(group)
                       .simplesort('lastActivityAt', true)

  @inboxDiscussions = (group) ->
    @allDiscussionsFor(group).limit(@loadedCount(group)).data()

  @inboxGroups = ->
    _.filter CurrentUser.groups(), (group) -> group.isParent()

  @groupName    = (group) ->
    group.name

  @anyThisGroup = (group) -> 
    @allDiscussionsFor(group).data().length > 0

  @canExpand    = (group) ->
    @loadedCount(group) < _.min [@allDiscussionsFor(group).data().length, @groupThreadCounts.expanded]

  @loadedCount  = (group) ->
    @groupThreadCounts[group.inboxStatus or 'normal']  

  @loadInbox()
  Records.votes.fetchMyRecentVotes()

  return