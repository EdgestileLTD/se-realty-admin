| import 'pages/applications/applications-list.tag'
| import 'pages/applications/applications-edit.tag'


applications
    .column
        applications-list(if='{ !edit }')
        applications-edit(if='{ edit }')

    script.
        var self = this,
            route = riot.route.create()

        self.edit = false

        route('/applications', function () {
            self.update({edit: false})
        })

        route('/applications/([0-9]+)', function (id) {
            app.trigger('applications-edit', id)
            self.update({edit: true})
        })

        route('/applications/new', function (tab) {
            self.update({edit: true, tab: 'applications'})
            app.trigger('applications-new')
        })

        route('/applications/*', function () {
            app.trigger('not-found')
        })

        self.on('mount', function () {
            riot.route.exec()
        })