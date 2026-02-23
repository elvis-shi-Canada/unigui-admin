unit UniModuleRegistry;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs,
  UniModuleRegistry.Intf;

type
  /// <summary>
  /// 插件注册表异常类
  /// 用于标识注册表操作中的错误情况
  /// </summary>
  ERegistryException = class(Exception)
  public
    constructor Create(const Msg: string); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); overload;
  end;

  /// <summary>
  /// 循环依赖异常类
  /// 当检测到循环依赖时抛出
  /// </summary>
  ECircularDependencyException = class(ERegistryException)
  public
    constructor Create(const CircularPath: string);
  end;

  /// <summary>
  /// 插件类注册器类
  /// 内部使用的注册器，管理单个插件类的注册信息
  /// </summary>
  TPluginClassRegistry = class
  private
    FPluginID: string;
    FInfo: TPluginClassInfo;
    FDependencies: TList<TDependencyInfo>;
  public
    constructor Create(const PluginID: string; const Info: TPluginClassInfo);
    destructor Destroy; override;

    property PluginID: string read FPluginID;
    property Info: TPluginClassInfo read FInfo write FInfo;
    property Dependencies: TList<TDependencyInfo> read FDependencies;
  end;

  /// <summary>
  /// 插件注册表实现类
  /// 全局单例模式，提供线程安全的插件注册和依赖管理
  /// </summary>
  TUniModuleRegistry = class(TInterfacedObject, IUniModuleRegistry)
  private
    class var
      FInstance: TUniModuleRegistry;
      FLock: TCriticalSection;

    FPluginRegistry: TDictionary<string, TPluginClassRegistry>;
    FDependencyGraph: TDictionary<string, TList<string>>;  // 邻接表表示的图
    FReverseDependencyGraph: TDictionary<string, TList<string>>;  // 反向依赖图
    FLock: TCriticalSection;

    procedure BuildDependencyGraphs;
    function DepthFirstSearch(const PluginID: string;
      const Visited: TDictionary<string, Boolean>;
      const RecursionStack: TDictionary<string, Boolean>;
      out Path: TStringList): Boolean;
    function DetectCircularDependencyInternal(const LVisited: TDictionary<string, Boolean>;
      const LRecursionStack: TDictionary<string, Boolean>;
      const LPath: TStringList;
      const StartPluginID: string): Boolean;
    function TopologicalSort: TArray<string>;
    procedure CheckPluginExists(const PluginID: string);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>获取全局单例实例</summary>
    class function GetInstance: IUniModuleRegistry;
    class procedure CleanupInstance;

    // IUniModuleRegistry 实现
    procedure RegisterPluginClass(const PluginClass: TClass; const PluginID: string;
      const Info: TPluginClassInfo);
    procedure UnregisterPluginClass(const PluginID: string);
    function IsPluginRegistered(const PluginID: string): Boolean;
    function GetPluginClassInfo(const PluginID: string): TPluginClassInfo;
    function GetAllPluginIDs: TArray<string>;
    function GetPluginsByCategory(const Category: string): TArray<string>;
    procedure AddDependency(const FromPluginID, ToPluginID, MinVersion: string);
    procedure RemoveDependency(const FromPluginID, ToPluginID: string);
    function GetDependencies(const PluginID: string): TArray<string>;
    function GetDependents(const PluginID: string): TArray<string>;
    function DetectCircularDependency(out CircularPath: string): Boolean;
    function CalculateLoadOrder: TArray<TLoadOrderInfo>;
    function ValidateDependencies(out MissingPlugins: TArray<string>): Boolean;
    function GetPluginCount: Integer;
    procedure Clear;
  end;

implementation

{ TPluginClassRegistry }

constructor TPluginClassRegistry.Create(const PluginID: string; const Info: TPluginClassInfo);
begin
  inherited Create;
  FPluginID := PluginID;
  FInfo := Info;
  FDependencies := TList<TDependencyInfo>.Create;
end;

destructor TPluginClassRegistry.Destroy;
begin
  FDependencies.Free;
  inherited;
end;

{ TUniModuleRegistry }

class function TUniModuleRegistry.GetInstance: IUniModuleRegistry;
begin
  if FInstance = nil then
  begin
    if FLock = nil then
      FLock := TCriticalSection.Create;
    FLock.Enter;
    try
      if FInstance = nil then
        FInstance := TUniModuleRegistry.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class procedure TUniModuleRegistry.CleanupInstance;
begin
  if FLock <> nil then
  begin
    FLock.Enter;
    try
      FInstance.Free;
      FInstance := nil;
    finally
      FLock.Leave;
    end;
  end;
end;

constructor TUniModuleRegistry.Create;
begin
  inherited Create;
  FPluginRegistry := TDictionary<string, TPluginClassRegistry>.Create;
  FDependencyGraph := TDictionary<string, TList<string>>.Create;
  FReverseDependencyGraph := TDictionary<string, TList<string>>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TUniModuleRegistry.Destroy;
begin
  Clear;
  FPluginRegistry.Free;
  FDependencyGraph.Free;
  FReverseDependencyGraph.Free;
  FLock.Free;
  inherited;
end;

procedure TUniModuleRegistry.RegisterPluginClass(const PluginClass: TClass;
  const PluginID: string; const Info: TPluginClassInfo);
var
  LRegistry: TPluginClassRegistry;
begin
  FLock.Enter;
  try
    if FPluginRegistry.ContainsKey(PluginID) then
      raise ERegistryException.CreateFmt('Plugin %s is already registered', [PluginID]);

    LRegistry := TPluginClassRegistry.Create(PluginID, Info);
    FPluginRegistry.Add(PluginID, LRegistry);

    // 初始化依赖图节点
    if not FDependencyGraph.ContainsKey(PluginID) then
      FDependencyGraph.Add(PluginID, TList<string>.Create);
    if not FReverseDependencyGraph.ContainsKey(PluginID) then
      FReverseDependencyGraph.Add(PluginID, TList<string>.Create);

    // 注册插件的依赖关系
    for var LDepID in Info.Dependencies do
      AddDependency(PluginID, LDepID, '');
  finally
    FLock.Leave;
  end;
end;

procedure TUniModuleRegistry.UnregisterPluginClass(const PluginID: string);
var
  LRegistry: TPluginClassRegistry;
  LDepList, LRevDepList: TList<string>;
begin
  FLock.Enter;
  try
    CheckPluginExists(PluginID);

    // 移除所有相关依赖
    if FDependencyGraph.TryGetValue(PluginID, LDepList) then
    begin
      for var LDepID in LDepList do
        RemoveDependency(PluginID, LDepID);
    end;

    // 移除反向依赖
    if FReverseDependencyGraph.TryGetValue(PluginID, LRevDepList) then
    begin
      for var LRevDepID in LRevDepList do
        RemoveDependency(LRevDepID, PluginID);
    end;

    // 清理图节点
    FDependencyGraph.Remove(PluginID);
    FReverseDependencyGraph.Remove(PluginID);

    // 移除注册表项
    LRegistry := FPluginRegistry[PluginID];
    FPluginRegistry.Remove(PluginID);
    LRegistry.Free;
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.IsPluginRegistered(const PluginID: string): Boolean;
begin
  FLock.Enter;
  try
    Result := FPluginRegistry.ContainsKey(PluginID);
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.GetPluginClassInfo(const PluginID: string): TPluginClassInfo;
begin
  FLock.Enter;
  try
    CheckPluginExists(PluginID);
    Result := FPluginRegistry[PluginID].Info;
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.GetAllPluginIDs: TArray<string>;
begin
  FLock.Enter;
  try
    Result := FPluginRegistry.Keys.ToArray;
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.GetPluginsByCategory(const Category: string): TArray<string>;
var
  LList: TList<string>;
begin
  FLock.Enter;
  try
    LList := TList<string>.Create;
    try
      for var LPair in FPluginRegistry do
        if LPair.Value.Info.Category = Category then
          LList.Add(LPair.Key);
      Result := LList.ToArray;
    finally
      LList.Free;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TUniModuleRegistry.AddDependency(const FromPluginID, ToPluginID, MinVersion: string);
var
  LDepInfo: TDependencyInfo;
  LDepList: TList<string>;
begin
  FLock.Enter;
  try
    CheckPluginExists(FromPluginID);
    // ToPluginID 可以暂时不存在，在验证时检查

    // 添加到依赖图
    if not FDependencyGraph.ContainsKey(FromPluginID) then
      FDependencyGraph.Add(FromPluginID, TList<string>.Create);
    FDependencyGraph[FromPluginID].Add(ToPluginID);

    // 添加到反向依赖图
    if not FReverseDependencyGraph.ContainsKey(ToPluginID) then
      FReverseDependencyGraph.Add(ToPluginID, TList<string>.Create);
    FReverseDependencyGraph[ToPluginID].Add(FromPluginID);

    // 添加到插件的依赖列表
    LDepInfo.FromPluginID := FromPluginID;
    LDepInfo.ToPluginID := ToPluginID;
    LDepInfo.DependencyType := 'strong';
    LDepInfo.MinVersion := MinVersion;
    FPluginRegistry[FromPluginID].Dependencies.Add(LDepInfo);
  finally
    FLock.Leave;
  end;
end;

procedure TUniModuleRegistry.RemoveDependency(const FromPluginID, ToPluginID: string);
var
  LRegistry: TPluginClassRegistry;
  I: Integer;
begin
  FLock.Enter;
  try
    CheckPluginExists(FromPluginID);

    // 从依赖图移除
    if FDependencyGraph.TryGetValue(FromPluginID, var LDepList) then
      LDepList.Remove(ToPluginID);

    // 从反向依赖图移除
    if FReverseDependencyGraph.TryGetValue(ToPluginID, var LRevDepList) then
      LRevDepList.Remove(FromPluginID);

    // 从插件依赖列表移除
    LRegistry := FPluginRegistry[FromPluginID];
    for I := LRegistry.Dependencies.Count - 1 downto 0 do
      if (LRegistry.Dependencies[I].FromPluginID = FromPluginID) and
         (LRegistry.Dependencies[I].ToPluginID = ToPluginID) then
        LRegistry.Dependencies.Delete(I);
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.GetDependencies(const PluginID: string): TArray<string>;
begin
  FLock.Enter;
  try
    CheckPluginExists(PluginID);
    if FDependencyGraph.TryGetValue(PluginID, var LDepList) then
      Result := LDepList.ToArray
    else
      Result := nil;
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.GetDependents(const PluginID: string): TArray<string>;
begin
  FLock.Enter;
  try
    if FReverseDependencyGraph.TryGetValue(PluginID, var LRevDepList) then
      Result := LRevDepList.ToArray
    else
      Result := nil;
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.DetectCircularDependency(out CircularPath: string): Boolean;
var
  LVisited: TDictionary<string, Boolean>;
  LRecursionStack: TDictionary<string, Boolean>;
  LPath: TStringList;
  LPluginID: string;
begin
  FLock.Enter;
  try
    LVisited := TDictionary<string, Boolean>.Create;
    LRecursionStack := TDictionary<string, Boolean>.Create;
    LPath := TStringList.Create;
    try
      // 初始化所有插件为未访问
      for LPluginID in FPluginRegistry.Keys do
      begin
        LVisited.Add(LPluginID, False);
        LRecursionStack.Add(LPluginID, False);
      end;

      // 检查每个插件
      for LPluginID in FPluginRegistry.Keys do
      begin
        if not LVisited[LPluginID] then
        begin
          if DetectCircularDependencyInternal(LVisited, LRecursionStack, LPath, LPluginID) then
          begin
            CircularPath := LPath.Text;
            Exit(True);
          end;
        end;
      end;

      CircularPath := '';
      Result := False;
    finally
      LVisited.Free;
      LRecursionStack.Free;
      LPath.Free;
    end;
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.DetectCircularDependencyInternal(
  const LVisited: TDictionary<string, Boolean>;
  const LRecursionStack: TDictionary<string, Boolean>;
  const LPath: TStringList;
  const StartPluginID: string): Boolean;
begin
  Result := False;
  LPath.Clear;

  if DepthFirstSearch(StartPluginID, LVisited, LRecursionStack, LPath) then
    Result := True;
end;

function TUniModuleRegistry.DepthFirstSearch(const PluginID: string;
  const Visited: TDictionary<string, Boolean>;
  const RecursionStack: TDictionary<string, Boolean>;
  out Path: TStringList): Boolean;
var
  LDepList: TList<string>;
  LNeighborID: string;
  LChildPath: TStringList;
begin
  Result := False;
  Path := TStringList.Create;

  Visited[PluginID] := True;
  RecursionStack[PluginID] := True;
  Path.Add(PluginID);

  if FDependencyGraph.TryGetValue(PluginID, LDepList) then
  begin
    for LNeighborID in LDepList do
    begin
      // 跳过未注册的依赖（在验证时处理）
      if not Visited.ContainsKey(LNeighborID) then
        Continue;

      if not Visited[LNeighborID] then
      begin
        if DepthFirstSearch(LNeighborID, Visited, RecursionStack, LChildPath) then
        begin
          Path.AddStrings(LChildPath);
          LChildPath.Free;
          Exit(True);
        end;
      end
      else if RecursionStack[LNeighborID] then
      begin
        // 找到循环
        Path.Add(LNeighborID);
        Exit(True);
      end;
    end;
  end;

  RecursionStack[PluginID] := False;
end;

function TUniModuleRegistry.CalculateLoadOrder: TArray<TLoadOrderInfo>;
var
  LSortedIDs: TArray<string>;
  LLoadOrderList: TList<TLoadOrderInfo>;
  LLoadInfo: TLoadOrderInfo;
  I, LLevel: Integer;
  LPluginID: string;
  LDepLevels: TDictionary<string, Integer>;
  LVisited: TList<string>;
  LVisitedDict: TDictionary<string, Boolean>;
  LRecursionStack: TDictionary<string, Boolean>;
  LCircularPath: TStringList;
begin
  FLock.Enter;
  try
    // 首先检查循环依赖（使用内部方法避免死锁）
    LVisitedDict := TDictionary<string, Boolean>.Create;
    LRecursionStack := TDictionary<string, Boolean>.Create;
    LCircularPath := TStringList.Create;
    try
      // 初始化所有插件为未访问
      for LPluginID in FPluginRegistry.Keys do
      begin
        LVisitedDict.Add(LPluginID, False);
        LRecursionStack.Add(LPluginID, False);
      end;

      // 检查每个插件
      for LPluginID in FPluginRegistry.Keys do
      begin
        if not LVisitedDict[LPluginID] then
        begin
          if DetectCircularDependencyInternal(LVisitedDict, LRecursionStack, LCircularPath, LPluginID) then
            raise ECircularDependencyException.Create(LCircularPath.Text);
        end;
      end;
    finally
      LVisitedDict.Free;
      LRecursionStack.Free;
      LCircularPath.Free;
    end;

    // 执行拓扑排序
    LSortedIDs := TopologicalSort;

    // 计算依赖层级
    LDepLevels := TDictionary<string, Integer>.Create;
    LVisited := TList<string>.Create;
    try
      for LPluginID in LSortedIDs do
      begin
        if FDependencyGraph.TryGetValue(LPluginID, var LDepList) then
        begin
          LLevel := 0;
          for var LDepID in LDepList do
          begin
            if LDepLevels.TryGetValue(LDepID, var LDepLevel) then
              LLevel := Max(LLevel, LDepLevel + 1);
          end;
          LDepLevels.Add(LPluginID, LLevel);
        end
        else
          LDepLevels.Add(LPluginID, 0);
      end;

      // 构建加载顺序信息
      LLoadOrderList := TList<TLoadOrderInfo>.Create;
      try
        for I := 0 to High(LSortedIDs) do
        begin
          LLoadInfo.PluginID := LSortedIDs[I];
          LLoadInfo.LoadOrder := I;
          LLoadInfo.DependencyLevel := LDepLevels[LSortedIDs[I]];
          LLoadOrderList.Add(LLoadInfo);
        end;
        Result := LLoadOrderList.ToArray;
      finally
        LLoadOrderList.Free;
      end;
    finally
      LDepLevels.Free;
      LVisited.Free;
    end;
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.TopologicalSort: TArray<string>;
var
  LInDegree: TDictionary<string, Integer>;
  LQueue: TQueue<string>;
  LResult: TList<string>;
  LPluginID, LCurrent: string;
  LDepList: TList<string>;
begin
  LInDegree := TDictionary<string, Integer>.Create;
  LQueue := TQueue<string>.Create;
  LResult := TList<string>.Create;
  try
    // 计算入度：A依赖B，则A的入度增加1（A需要等待B先加载）
    for LPluginID in FPluginRegistry.Keys do
      LInDegree.Add(LPluginID, 0);

    // 反向依赖图用于计算入度：谁依赖我，我就让谁的入度增加
    if FReverseDependencyGraph.Count > 0 then
    begin
      for LPluginID in FPluginRegistry.Keys do
      begin
        if FReverseDependencyGraph.TryGetValue(LPluginID, LDepList) then
        begin
          // LDepList中存储的是依赖LPluginID的所有插件
          // 这些插件的入度需要增加1
          for var LDependentID in LDepList do
          begin
            if LInDegree.ContainsKey(LDependentID) then
              LInDegree[LDependentID] := LInDegree[LDependentID] + 1;
          end;
        end;
      end;
    end;

    // 将入度为0的节点加入队列（没有依赖或所有依赖都已处理）
    for LPluginID in FPluginRegistry.Keys do
    begin
      if LInDegree[LPluginID] = 0 then
        LQueue.Enqueue(LPluginID);
    end;

    // 处理队列
    while LQueue.Count > 0 do
    begin
      LCurrent := LQueue.Dequeue;
      LResult.Add(LCurrent);

      // 查找依赖LCurrent的所有插件，减少它们的入度
      if FReverseDependencyGraph.TryGetValue(LCurrent, LDepList) then
      begin
        for var LDependentID in LDepList do
        begin
          if LInDegree.ContainsKey(LDependentID) then
          begin
            LInDegree[LDependentID] := LInDegree[LDependentID] - 1;
            if LInDegree[LDependentID] = 0 then
              LQueue.Enqueue(LDependentID);
          end;
        end;
      end;
    end;

    // 检查是否所有节点都被处理（应该不会有循环，因为前面已检查）
    if LResult.Count <> FPluginRegistry.Count then
      raise ECircularDependencyException.Create('Unable to determine load order');

    Result := LResult.ToArray;
  finally
    LInDegree.Free;
    LQueue.Free;
    LResult.Free;
  end;
end;

function TUniModuleRegistry.ValidateDependencies(
  out MissingPlugins: TArray<string>): Boolean;
var
  LMList: TList<string>;
  LPluginID, LDepID: string;
  LDepList: TList<string>;
begin
  FLock.Enter;
  try
    LMList := TList<string>.Create;
    try
      for LPluginID in FPluginRegistry.Keys do
      begin
        if FDependencyGraph.TryGetValue(LPluginID, LDepList) then
        begin
          for LDepID in LDepList do
          begin
            if not FPluginRegistry.ContainsKey(LDepID) then
              LMList.Add(LDepID);
          end;
        end;
      end;

      if LMList.Count > 0 then
      begin
        MissingPlugins := LMList.ToArray;
        Result := False;
      end
      else
      begin
        MissingPlugins := nil;
        Result := True;
      end;
    finally
      LMList.Free;
    end;
  finally
    FLock.Leave;
  end;
end;

function TUniModuleRegistry.GetPluginCount: Integer;
begin
  FLock.Enter;
  try
    Result := FPluginRegistry.Count;
  finally
    FLock.Leave;
  end;
end;

procedure TUniModuleRegistry.Clear;
var
  LPair: TPair<string, TPluginClassRegistry>;
  LList: TList<string>;
begin
  FLock.Enter;
  try
    // 释放所有注册表项
    for LPair in FPluginRegistry do
      LPair.Value.Free;
    FPluginRegistry.Clear;

    // 清理依赖图
    for LList in FDependencyGraph.Values do
      LList.Free;
    FDependencyGraph.Clear;

    // 清理反向依赖图
    for LList in FReverseDependencyGraph.Values do
      LList.Free;
    FReverseDependencyGraph.Clear;
  finally
    FLock.Leave;
  end;
end;

procedure TUniModuleRegistry.CheckPluginExists(const PluginID: string);
begin
  if not FPluginRegistry.ContainsKey(PluginID) then
    raise ERegistryException.CreateFmt('Plugin %s is not registered', [PluginID]);
end;

{ ERegistryException }

constructor ERegistryException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

constructor ERegistryException.CreateFmt(const Msg: string; const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
end;

{ ECircularDependencyException }

constructor ECircularDependencyException.Create(const CircularPath: string);
begin
  inherited CreateFmt('Circular dependency detected: %s', [CircularPath]);
end;

initialization
  // 单例在首次使用时创建

finalization
  // 清理全局单例
  TUniModuleRegistry.CleanupInstance;
  if TUniModuleRegistry.FLock <> nil then
    TUniModuleRegistry.FLock.Free;

end.
