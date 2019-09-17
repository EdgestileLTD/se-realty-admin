| import 'components/catalog.tag'
| import 'lodash/lodash'

question-list
    catalog(search='true', sortable='true', object='Question', cols='{ cols }', reload='true',
    add='{ permission(add, "questions", "0100") }',
    remove='{ permission(remove, "questions", "0001") }',
    dblclick='{ permission(commentOpen, "questions", "1000") }',
    store='question-list')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='createdAt') { row.createdAt }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='email') { row.email }
            datatable-cell(name='question') { _.truncate(row.question.replace( /<.*?>/g, '' ), {length: 50}) }
            datatable-cell(name='answer') { _.truncate(row.answer.replace( /<.*?>/g, '' ), {length: 50}) }

    script(type='text/babel').
        var self = this

        self.collection = 'Question'

        self.mixin('permissions')
        self.mixin('remove')

        self.add = () => {
            riot.route('/questions/new')
        }







        self.cols = [
            {name: 'id', value: '#'},
            {name: 'createdAt', value: 'Дата/время'},
            {name: 'name', value: 'Пользователь'},
            {name: 'email', value: 'Email пользователя'},
            {name: 'question', value: 'Вопрос'},
            {name: 'answer', value: 'Ответ'}
        ]

        self.commentOpen = e => {
            riot.route(`/questions/${e.item.row.id}`)
        }

        observable.on('questions-reload', () => {
            self.tags.catalog.reload()
        })


