import "@azure-tools/typespec-azure-core";
import "@typespec/rest";
import "./models.tsp";
import "@azure-tools/typespec-azure-resource-manager";
import "@azure-tools/typespec-client-generator-core";

using TypeSpec.Rest;
using TypeSpec.Http;
using Azure.Core;
using Azure.ClientGenerator.Core;
using Azure.ResourceManager;
using Azure.ResourceManager.Foundations;
using OpenAPI;

namespace Microsoft.AzureTerraform;

@doc("Parameters common to all ExportTerraform operations")
model CommonExportTerraformParameters {
  ...ApiVersionParameter;
  ...SubscriptionIdParameter;
}

#suppress "@azure-tools/typespec-azure-resource-manager/arm-resource-interface-requires-decorator" "Cannot use @armResourceOperations, the implied @autoRoute produces the wrong route for GET /operationStatuses/{operationId}"
interface ExportTerraform {
  // Cannot use Azure.ResourceManager.ArmProviderActionAsync due to error during .NET SDK code generation:
  // Unknown identifier SubscriptionActionScope
  #suppress "@azure-tools/typespec-azure-core/no-openapi" "Need to override @operationId to fix LintDiff"
  @armResourceAction(ExportResult)
  @doc("Exports the Terraform configuration of the specified resource(s).")
  @route("/subscriptions/{subscriptionId}/providers/Microsoft.AzureTerraform/exportTerraform")
  @post
  @tag("ExportTerraform")
  // @useFinalStateVia("azure-async-operation")
  exportTerraform(
    ...CommonExportTerraformParameters,

    // Body parameter cannot be named 'body' or else we will encounter error at .NET SDK generation: Unhandled exception. System.InvalidOperationException: Attempting to get the discriminator value for property `type` on object type BaseExportModel but got none or non-primitive type
    @doc("The export parameter")
    @bodyRoot
    exportParameter: BaseExportModel,
  ): ArmAcceptedLroResponse<
    "Resource operation accepted.",
    ArmLroLocationHeader<
      Azure.Core.StatusMonitorPollingOptions<ArmOperationStatus>,
      ExportResult,
      string
    > &
      Azure.Core.Foundations.RetryAfterHeader
  > | ExportResult | ErrorResponse;
}
