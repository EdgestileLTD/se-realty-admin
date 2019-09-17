| import 'lodash/lodash'

notice-log
    h4 Лог уведомлений

    catalog(object='NoticeLog', cols='{ cols }', reload='true', handlers='{ handlers }',
        remove='{ remove }',
        dblclick='{ open }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='dateDisplay') { row.dateDisplay }
            datatable-cell(name='recipient') { row.recipient }
            datatable-cell(name='content') { _.truncate(row.content.replace( /<.*?>/g, '' ), {length: 50}) }
            datatable-cell(name='status') { row.status }
            datatable-cell(name='serviceInfo') { row.serviceInfo }


    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')

        self.collection = 'NoticeLog'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'dateDisplay', value: 'Дата'},
            {name: 'recipient', value: 'Получатель'},
            {name: 'content', value: 'Сообщение'},
            {name: 'status', value: 'Статус'},
            {name: 'serviceInfo', value: 'Служебная информация'},

        ]

        self.open = e => riot.route(`settings/notice/${e.item.row.idNotice}`)

        observable.on('notices-log-reload', () => {
            self.tags.catalog.reload()
        })
