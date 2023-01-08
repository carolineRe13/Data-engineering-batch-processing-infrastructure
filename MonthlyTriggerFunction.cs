using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Extensions.Logging;


namespace DataEngineering
{
    public static class MonthlyTriggerFunction
    {
        // monthly
        // const string TIMER_CONFIGURATION = "0 0 0 1 * *";

        // every minute
        const string TIMER_CONFIGURATION = "0 */2 * * * *";

        [FunctionName("MonthlyTriggerFunction")]
        public static async Task<List<string>> RunOrchestrator(
            [OrchestrationTrigger] IDurableOrchestrationContext context)
        {
            var outputs = new List<string>();

            // Replace "hello" with the name of your Durable Activity Function.
            outputs.Add(await context.CallActivityAsync<string>(nameof(SayHello), "Tokyo"));
            outputs.Add(await context.CallActivityAsync<string>(nameof(SayHello), "Seattle"));
            outputs.Add(await context.CallActivityAsync<string>(nameof(SayHello), "London"));

            // returns ["Hello Tokyo!", "Hello Seattle!", "Hello London!"]
            return outputs;
        }

        [FunctionName(nameof(SayHello))]
        public static string SayHello([ActivityTrigger] string name, ILogger log)
        {
            log.LogInformation($"Saying hello to {name}.");
            return $"Hello {name}!";
        }

        [FunctionName("MonthlyTriggerFunction_MonthlyStart")]
        public static async Task MonthlyStart(
            [TimerTrigger(TIMER_CONFIGURATION)] TimerInfo myTimer,
            [DurableClient] IDurableOrchestrationClient starter,
            ILogger log)
        {
            // Function input comes from the request content.
            string instanceId = await starter.StartNewAsync("MonthlyTriggerFunction", null);

            log.LogInformation($"Started orchestration with ID = '{instanceId}'.");
        }
    }
}