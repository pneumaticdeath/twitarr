Twitarr.ScheduleDayController = Twitarr.ObjectController.extend
  today_text: (->
    moment(@get('today')).format('ddd MMM Do')
  ).property('today')
  next_day_text: (->
    moment(@get('next_day')).format('ddd >')
  ).property('next_day')
  prev_day_text: (->
    moment(@get('prev_day')).format('< ddd')
  ).property('prev_day')

  actions:
    next_day: ->
      @transitionToRoute 'schedule.day', @get('next_day')
    prev_day: ->
      @transitionToRoute 'schedule.day', @get('prev_day')

Twitarr.ScheduleTodayController = Twitarr.ScheduleDayController.extend()

Twitarr.ScheduleMetaPartialController = Twitarr.ObjectController.extend
  followable: (->
    @get('logged_in') and not @get('following')
  ).property('logged_in', 'following')

  unfollowable: (->
    @get('logged_in') and @get('following')
  ).property('logged_in', 'following')

  actions:
    follow: ->
      Ember.run =>
        @get('model').follow()
    unfollow: ->
      Ember.run =>
        @get('model').unfollow()

Twitarr.ScheduleDetailController = Twitarr.ObjectController.extend
  editable: (->
    @get('login_admin')
  ).property('login_admin')

  actions:
    follow: ->
      @get('model').follow()
    unfollow: ->
      @get('model').unfollow()
    edit: ->
      @transitionToRoute 'schedule.edit', @get('id')
    delete: ->
      if(confirm("Are you sure you want to delete this event?"))
        r=@get('model').delete()
        @transitionToRoute 'schedule' if r
    ical: ->
      window.location.replace("/api/v2/event/#{@get('id')}/ical")

Twitarr.ScheduleNewController = Twitarr.Controller.extend
  init: ->
    @set 'errors', Ember.A()

  start_time: (->
    getUsableTimeValue()
  ).property()

  actions:
    new: ->
      return if @get('posting')
      @set 'posting', true
      Twitarr.Event.new_event(@get('title'), @get('description'), @get('location'), @get('start_time'), @get('end_time')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
        else
          @set 'title', ''
          @set 'description', ''
          @set 'location', ''
          @set 'start_time', getUsableTimeValue()
          @set 'end_time', ''
          @set 'posting', false
          @get('errors').clear()
          @transitionToRoute 'schedule'
      , ->
        @set 'posting', false
        alert 'Event could not be added. Please try again later. Or try again someplace without so many seamonkeys.'
      )

Twitarr.ScheduleEditController = Twitarr.ObjectController.extend
  errors: Ember.A()

  actions:
    save: ->
      return if @get('posting')
      @set 'posting', true
      Twitarr.Event.edit(@get('id'), @get('description'), @get('location'), @get('start_time'), @get('end_time')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @get('errors').clear()
          @set 'posting', false
          @transitionToRoute 'schedule.detail', @get('id')
      , =>
        @set 'posting', false
        alert 'Event could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )

getUsableTimeValue = -> d = new Date(); d.toISOString().replace('Z', '').replace(/:\d{2}\.\d{3}/, '')