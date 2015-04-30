angular.module('loomioApp').controller 'ProposalFormController', ($scope, $modalInstance, proposal, FlashService) ->
  $scope.proposal = proposal

  $scope.submit = ->
    proposal.save().then ->
      $modalInstance.close()
      if proposal.isNew()
        FlashService.success 'proposal_form.messages.created'
      else
        FlashService.success 'proposal_form.messages.updated'

  $scope.cancel = ->
    $modalInstance.dismiss()
