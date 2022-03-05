import Text "mo:base/Text";
import Nat "mo:base/Nat";

actor CounterHttpRequest {
  stable var currentValue : Nat = 0;

  // Increment the counter with the increment function.
  public func increment() : async () {
    currentValue += 1;
  };

  // Read the counter value with a get function.
  public query func get() : async Nat {
    currentValue
  };

  // Write an arbitrary value with a set function.
  public func set(n: Nat) : async () {
    currentValue := n;
  };

  public type BatchId = Nat;
  public type BatchOperationKind = {
    #CreateAsset : CreateAssetArguments;
    #UnsetAssetContent : UnsetAssetContentArguments;
    #DeleteAsset : DeleteAssetArguments;
    #SetAssetContent : SetAssetContentArguments;
    #Clear : ClearArguments;
  };
  public type ChunkId = Nat;
  public type ClearArguments = {};
  public type CreateAssetArguments = { key : Key; content_type : Text };
  public type DeleteAssetArguments = { key : Key };
  public type HeaderField = (Text, Text);
  public type HttpRequest = {
    url : Text;
    method : Text;
    body : [Nat8];
    headers : [HeaderField];
  };
  public type HttpResponse = {
    body : Blob;
    headers : [HeaderField];
    streaming_strategy : ?StreamingStrategy;
    status_code : Nat16;
  };
  public type Key = Text;
  public type SetAssetContentArguments = {
    key : Key;
    sha256 : ?[Nat8];
    chunk_ids : [ChunkId];
    content_encoding : Text;
  };
  public type StreamingCallbackHttpResponse = {
    token : ?StreamingCallbackToken;
    body : [Nat8];
  };
  public type StreamingCallbackToken = {
    key : Key;
    sha256 : ?[Nat8];
    index : Nat;
    content_encoding : Text;
  };
  public type StreamingStrategy = {
    #Callback : {
      token : StreamingCallbackToken;
      callback : shared query StreamingCallbackToken -> async ?StreamingCallbackHttpResponse;
    };
  };
  public type Time = Int;
  public type UnsetAssetContentArguments = {
    key : Key;
    content_encoding : Text;
  };
  public type Self = actor {
    authorize : shared Principal -> async ();
    clear : shared ClearArguments -> async ();
    commit_batch : shared {
        batch_id : BatchId;
        operations : [BatchOperationKind];
      } -> async ();
    create_asset : shared CreateAssetArguments -> async ();
    create_batch : shared {} -> async { batch_id : BatchId };
    create_chunk : shared { content : [Nat8]; batch_id : BatchId } -> async {
        chunk_id : ChunkId;
      };
    delete_asset : shared DeleteAssetArguments -> async ();
    get : shared query { key : Key; accept_encodings : [Text] } -> async {
        content : [Nat8];
        sha256 : ?[Nat8];
        content_type : Text;
        content_encoding : Text;
        total_length : Nat;
      };
    get_chunk : shared query {
        key : Key;
        sha256 : ?[Nat8];
        index : Nat;
        content_encoding : Text;
      } -> async { content : [Nat8] };
    http_request : shared query HttpRequest -> async HttpResponse;
    http_request_streaming_callback : shared query StreamingCallbackToken -> async ?StreamingCallbackHttpResponse;
    list : shared query {} -> async [
        {
          key : Key;
          encodings : [
            {
              modified : Time;
              sha256 : ?[Nat8];
              length : Nat;
              content_encoding : Text;
            }
          ];
          content_type : Text;
        }
      ];
    set_asset_content : shared SetAssetContentArguments -> async ();
    store : shared {
        key : Key;
        content : [Nat8];
        sha256 : ?[Nat8];
        content_type : Text;
        content_encoding : Text;
      } -> async ();
    unset_asset_content : shared UnsetAssetContentArguments -> async ();
  };

  public shared query func http_request(request : HttpRequest) : async HttpResponse {
    {
      body = Text.encodeUtf8("<html><body><h1>" # Nat.toText(currentValue) #"</h1></body></html>");
      headers = [];
      streaming_strategy = null;
      status_code = 200;
    }
  }
}
