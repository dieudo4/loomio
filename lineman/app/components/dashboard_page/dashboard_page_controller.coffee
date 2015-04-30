angular.module('loomioApp').controller 'DashboardPageController', ($rootScope, Records, CurrentUser, LoadingService) ->
  $rootScope.$broadcast('currentComponent', 'dashboardPage')
  $rootScope.$broadcast('setTitle', 'Dashboard')

  @loaded = {}
  @perPage = 25

  @filter = -> CurrentUser.dashboardFilter

  @loadedCount = =>
    @loaded[@filter()] = @loaded[@filter()] or 0

  @updateLoadedCount = =>
    current = @loadedCount()
    @loaded[@filter()] = current + @perPage

  @loadParams = ->
    filter: @filter()
    per:    @perPage
    from:   @loadedCount()

  @loadMore = =>
    Records.discussions.fetchInboxByDate(@loadParams()).then @updateLoadedCount
  LoadingService.applyLoadingFunction @, 'loadMore'

  @changePreferences = (options = {}) =>
    CurrentUser.updateFromJSON(options)
    CurrentUser.save()
    @loadMore() if @loadedCount() == 0

  @dashboardOptions = =>
    muted:     @filter() == 'show_muted'
    unread:    @filter() == 'show_unread'
    proposals: @filter() == 'show_proposals'

  @dashboardDiscussionReaders = =>
    _.pluck Records.discussionReaders.forDashboard(@dashboardOptions()).data(), 'id'

  @dashboardDiscussions = =>
    Records.discussions.findByDiscussionIds(@dashboardDiscussionReaders())
                       .simplesort('lastActivityAt', true)
                       .limit(@loadedCount())
                       .data()

  timeframe = (options = {}) ->
    today = moment().startOf 'day'
    (discussion) ->
      discussion.lastInboxActivity()
                .isBetween(today.clone().subtract(options['fromCount'] or 1, options['from']),
                           today.clone().subtract(options['toCount'] or 1, options['to']))

  inTimeframe = (fn) ->
    => @loadedCount() > 0 and _.find @dashboardDiscussions(), (discussion) => fn(discussion)

  @today     = timeframe(from: 'second', toCount: -10, to: 'year')
  @yesterday = timeframe(from: 'day', to: 'second')
  @thisWeek  = timeframe(from: 'week', to: 'day')
  @thisMonth = timeframe(from: 'month', to: 'week')
  @older     = timeframe(fromCount: 3, from: 'month', to: 'month')

  @anyToday     = inTimeframe(@today)
  @anyYesterday = inTimeframe(@yesterday)
  @anyThisWeek  = inTimeframe(@thisWeek)
  @anyThisMonth = inTimeframe(@thisMonth)
  @anyOlder     = inTimeframe(@older)

  Records.votes.fetchMyRecentVotes()
  @loadMore()

  return
