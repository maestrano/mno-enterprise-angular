# wordwise (boolean) - if true, cut only by words bounds,
angular.module 'mnoEnterpriseAngular'
  .filter("filterQuestions", ->
    (questions, keyword) ->
      result = {}
      keyword = keyword.toLowerCase()
      angular.forEach(questions, (question, key) ->
        result[key] = question if (questionMatch(question, keyword) || answerMatch(question, keyword))
      )
      return result

  questionMatch = (question, keyword) ->
    return question.description.toLowerCase().includes(keyword)

  answerMatch = (question, keyword) ->
    result = false
    _.each(question.answers, (answer) ->
      result = true if answer.description.toLowerCase().includes(keyword)
      true
    )
    return result
)
