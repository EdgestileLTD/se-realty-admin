| import 'pages/mailing/mailing-list.tag'
| import 'pages/mailing/mailing-edit.tag'

mailing
    .column(if='{ !notFound }')
        mailing-list(if='{ !edit }')
        mailing-edit(if='{ edit }')

    script(type='text/babel').
        var self = this,
        route = riot.route.create()

        self.edit = false

        route('/mailing', function () {
            self.notFound = false
            self.edit = false
            self.update()
        })

        route('/mailing/([0-9]+)', function (id) {
            observable.trigger('mailing-edit', id)
            self.notFound = false
            self.edit = true
            self.update()
        })

        route('/mailing/new', function () {
            self.update({edit: true, notFound: false})
            observable.trigger('mailing-new')
        })

        route('/mailing..', () => {
            self.notFound = true
            self.update()
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })
