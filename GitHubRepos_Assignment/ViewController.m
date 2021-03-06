//
//  ViewController.m
//  GitHubRepos_Assignment
//
//  Created by Nathan Wainwright on 2018-08-16.
//  Copyright © 2018 Nathan Wainwright. All rights reserved.
//

#import "ViewController.h"
#import "Repo.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *repoTableView;

@property (strong, nonatomic) NSMutableArray *reproNames;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reproNames = [NSMutableArray new];
    
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/users/zenFish00/repos"]; // 1 MAIN
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url]; // 2 MAIN
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration]; // 3 MAIN
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration]; // 4 MAIN
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // COMPLETION HANDLER
        if (error) { // 1
            // Handle the error
            NSLog(@"error: %@", error.localizedDescription);
            return;
        }
        NSError *jsonError = nil;
        NSArray *repos = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError]; // 2
        if (jsonError) { // 3
            // Handle the error
            NSLog(@"jsonError: %@", jsonError.localizedDescription);
            return;
        }
        // If we reach this point, we have successfully retrieved the JSON from the API
        for (NSDictionary *repo in repos) { // 4
            Repo *repoTempObject = [[Repo alloc] init];
            repoTempObject.gitRepoNames = repo[@"name"];
            //            NSString *repoName = repo[@"name"];
            //            NSLog(@"repo: %@", repoName);
            
            [self.reproNames addObject:repoTempObject];
        }
        
        //        NSLog(@"TEST: %@", self.reproNames);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.repoTableView reloadData];
        }];
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [self.repoTableView reloadData];
        //        });
        
        //        [self.repoTableView reloadData];
        
    }]; // 5 MAIN
    
    [dataTask resume]; // 6 MAIN
    
} // END VIEW DID LOAD

// 1 MAIN  Create a new NSURL object from the github url string.
//2 MAIN Create a new NSURLRequest object using the URL object. Use this object to make configurations specific to the URL. For example, specifying if this is a GET or POST request, or how we should cache data.
// 3 MAIN An NSURLSessionConfiguration object defines the behavior and policies to use when making a request with an NSURLSession object. We can set things like the caching policy on this object, similar to the NSURLRequest object, but we can use the session configuration to create many different requests, where any configurations we make to the NSURLRequest object will only apply to that single request. The default system values are good for now, so we'll just grab the default configuration.
//  4 MAIN Create an NSURLSession object using our session configuration. Any changes we want to make to our configuration object must be done before this.
// 5 MAIN We create a task that will actually get the data from the server. The session creates and configures the task and the task makes the request. Data tasks send and receive data using NSData objects. Data tasks are intended for short, often interactive requests to a server. Check out the NSURLSession API Referece for more info on this. We could optionally use a delegate to get notified when the request has completed, but we're going to use a completion block instead. This block will get called when the network request is complete, weather it was successful or not.
// 6 MAIN A task is created in a suspended state, so we need to resume it. We can also suspend, resume, and cancel tasks whenever we want. This can be incredibly useful when downloading larger files using a download task.

//The completion handler takes 3 parameters:
//
//data: The data returned by the server, most of the time this will be JSON or XML.
//response: Response metadata such as HTTP headers and status codes.
//error: An NSError that indicates why the request failed, or nil when the request is successful.
//1 If there was an error, we want to handle it straight away so we can fix it. Here we're checking if there was an error, logging the description, then returning out of the block since there's no point in continuing.
//2 The data task retrieves data from the server as an NSData object because the server could return anything. We happen to know that this server is returning JSON so we need a way to convert this data to JSON. Luckily we can just use the NSJSONSerialization object to do just that. We know that the top level object in the JSON response is a JSON object (not an array or string) so we're setting the json as a dictionary.
// 3 If there was an error getting JSON from the NSData, like if the server actually returned XML to us, then we want to handle it here.
// 4 If we get to this point, we have the JSON data back from our request, so let's use it. When we made this request in our browser, we saw something similar to this:

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    //    cell.textLabel.text = @"Amir";
    //    cell.textLabel.text = self.reproNames[indexPath.item];
    Repo *tempObj = [[Repo alloc] init];
    tempObj = self.reproNames[indexPath.item];
    cell.textLabel.text = tempObj.gitRepoNames;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reproNames.count;
}

@end
