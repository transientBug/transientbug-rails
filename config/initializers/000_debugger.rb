if defined? ap
  def ap object, options={ indent: -2 }
    super
  end
end

if defined? PryByebug
  Pry.commands.alias_command "c", "continue"
  Pry.commands.alias_command "s", "step"
  Pry.commands.alias_command "n", "next"
  Pry.commands.alias_command "f", "finish"
  Pry.commands.alias_command "q", "quit"
end

if defined? Pry
  Pry::Commands.command %r{^$}, "repeat last command" do
    _pry_.run_command Pry.history.to_a.last
  end
end

if defined? RubyProf
  def profile name, &block
    result = RubyProf.profile(&block)

    profile_output = ETL.root.join "profile", ETL.environment.to_s, "#{ name }.html"
    profile_output.parent.mkpath

    printer = RubyProf::CallStackPrinter.new result
    printer.print profile_output.open("w")
  end
end
