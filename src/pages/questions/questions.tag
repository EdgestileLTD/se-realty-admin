| import 'pages/questions/question-list.tag'
| import 'pages/questions/question-edit.tag'

questions
    .column(if='{ !notFound }')
        question-list(if='{ !edit }')
        question-edit(if='{ edit }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        self.edit = false

        route('/questions', function () {
            self.notFound = false
            self.edit = false
            self.update()
        })

        route('/questions/([0-9]+)', function (id) {
            observable.trigger('question-edit', id)
            self.notFound = false
            self.edit = true
            self.update()
        })

        route('/questions/new', function () {
            self.notFound = false
            self.edit = true
            observable.trigger('question-new')
            self.update()
        })

        route('/questions..', () => {
            self.notFound = true
            self.update()
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })